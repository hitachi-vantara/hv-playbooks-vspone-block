import requests
from requests.auth import HTTPBasicAuth
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--sdsc-endpoint", required=True)
parser.add_argument("--current-password", required=True)
parser.add_argument("--new-password", required=True)
args = parser.parse_args()

reset_url = f"{args.sdsc_endpoint}/ConfigurationManager/simple/v1/objects/users/admin/password"

payload = {
    "currentPassword": args.current_password,
    "newPassword": args.new_password
}

# Basic auth with admin + temporary password
response = requests.patch(
    reset_url,
    json=payload,
    auth=HTTPBasicAuth("admin", args.current_password),
    verify=False
)

if response.status_code == 200:
    print("Password reset successfully")
else:
    print(f"Failed to reset password: {response.status_code} {response.text}")
