#!/usr/bin/env python3
import requests
import subprocess
import time
import logging
import os
import re
from requests.auth import HTTPBasicAuth

# Load environment variables from .env
from dotenv import load_dotenv
load_dotenv("/opt/jira-storage-poller/.env")

# Ensure logs directory exists
log_dir = "/opt/jira-storage-poller/logs"
os.makedirs(log_dir, exist_ok=True)

# Set up logging
logging.basicConfig(
    filename=f"{log_dir}/poller.log",
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)

# Config
JIRA_URL = os.getenv("JIRA_URL")
JIRA_USER = os.getenv("JIRA_USER")
JIRA_TOKEN = os.getenv("JIRA_TOKEN")
JIRA_PROJECT = "IPSESE"
JIRA_JQL = f"project = {JIRA_PROJECT} AND status = \"To Do\" AND labels = LUN-Request"
JIRA_API_ISSUE = f"{JIRA_URL}/rest/api/2/issue"

POLL_INTERVAL = 60  # seconds

PROCESSED_LABEL = "lun_processed"

def parse_description(description):
    size = 1  # default if not specified

    try:
        match = re.search(r"size\s*[:=]?\s*(\d+)", str(description), re.IGNORECASE)
        if match:
            size = int(match.group(1))
        else:
            logging.warning("Size not found in description")
    except Exception as e:
        logging.warning(f"Failed to parse size: {e}")

    return size

# Poll loop
while True:
    try:
        logging.info("Checking Jira for new LUN requests...")

        # Query Jira
        response = requests.get(
            f"{JIRA_URL}/rest/api/2/search",
            params={"jql": JIRA_JQL},
            auth=HTTPBasicAuth(JIRA_USER, JIRA_TOKEN),
            headers={"Accept": "application/json"}
        )

        response.raise_for_status()
        data = response.json()

        for issue in data.get("issues", []):
            key = issue["key"]
            desc = issue["fields"].get("description", "")
            labels = issue["fields"].get("labels", [])

            if PROCESSED_LABEL in labels:
                logging.info(f"Skipping {key} — already processed")
                continue

            logging.info(f"Found issue: {key} - parsing description")
            size = parse_description(desc)

            # Call Ansible playbook
            result = subprocess.run([
                "ansible-playbook",
                "/home/imran/.ansible/collections/ansible_collections/hitachivantara/vspone_block/playbooks/vsp_direct/im_ldev_jira.yml",
                "-e", f"ticket={key} size={size}"
            ], capture_output=True, text=True)

            logging.info(f"Ran playbook for {key} — return code {result.returncode}")

            # Add comment to Jira
            comment = {
                "body": f"✅ LUN requested via automation.\nSize: {size} GB\nReturn Code: {result.returncode}"
            }

            comment_url = f"{JIRA_API_ISSUE}/{key}/comment"
            requests.post(
                comment_url,
                auth=HTTPBasicAuth(JIRA_USER, JIRA_TOKEN),
                json=comment,
                headers={"Content-Type": "application/json"}
            )

            # Immediately mark issue as processed to prevent double execution
            label_url = f"{JIRA_API_ISSUE}/{key}"
            label_payload = {
                "update": {
                    "labels": [{"add": PROCESSED_LABEL}]
                }
            }
            label_response = requests.put(
                label_url,
                auth=HTTPBasicAuth(JIRA_USER, JIRA_TOKEN),
                json=label_payload,
                headers={"Content-Type": "application/json"}
            )
            if label_response.status_code != 204:
                logging.warning(f"Label update may have failed for {key}: {label_response.status_code}")

    except Exception as e:
        logging.error(f"Error in Jira poller: {e}")

    time.sleep(POLL_INTERVAL)
