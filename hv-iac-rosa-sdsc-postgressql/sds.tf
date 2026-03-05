
data "aws_subnet" "control_subnet" {
  id = var.control_subnet_id
}

resource "aws_cloudformation_stack" "parent_stack" {
  name          = "${var.cluster_name}-ParentStack"
  template_body = <<EOT
AWSTemplateFormatVersion: 2010-09-09
Description: Configuring the storage nodes for deploying VSP One SDS Block.

# ----------------------------------------------------------------
#     Parameters
# Define items to be entered by the user.
# ----------------------------------------------------------------

Conditions:
  StorageClusterDuplicationCreate:
    "Fn::And": [
      {"Fn::Equals": ["Duplication", "Fn::Select": ["1", "Fn::Split": [" ", "Ref": ConfigurationPattern]]]},
      {"Fn::Equals": ["Duplication", "Fn::Select": ["1", "Fn::Split": [" ", "Ref": PhysicalDriveCapacity]]]}
    ]
  StorageCluster4D2PCreate:
    "Fn::And": [
      {"Fn::Equals": ["4D+2P","Fn::Select": ["1", "Fn::Split": [" ", "Ref": ConfigurationPattern]]]},
      {"Fn::Equals": ["4D+2P","Fn::Select": ["1", "Fn::Split": [" ", "Ref": PhysicalDriveCapacity]]]}
    ]

Parameters:
  ClusterName:
    Description: Enter the name of VSP One SDS Block cluster.
    Type: String
    AllowedPattern: ^[a-zA-Z][a-zA-Z0-9-]{0,19}+$
    Default: VSPOneSDSBlock

  AvailabilityZone:
    Description: Select the availability zone.
    Type: AWS::EC2::AvailabilityZone::Name

  VpcId:
    Description: Select the ID of the VPC that was specified when creating the storage cluster.
    Type: AWS::EC2::VPC::Id

  ControlSubnetId:
    Description: Select the ID of the subnet for the control network.
    Type: AWS::EC2::Subnet::Id

  ControlNetworkCidrBlock:
    Description: Enter the IP range of the subnet for the control network.
    Type: String

  InterNodeSubnetId:
    Description: Select the ID of the subnet for the internode network.
    Type: AWS::EC2::Subnet::Id

  ComputeSubnetId:
    Description: Select the ID of the subnet for the compute network.
    Type: AWS::EC2::Subnet::Id

  ComputeIpVersion:
    Description: Select the Internet Protocol version to be used on the compute network.
    Type: String
    AllowedValues: ["ipv4", "ipv4v6"]
    Default: "ipv4"

  StorageNodeInstanceType:
    Description: Select the instance type for each storage node.
    Type: String
    AllowedValues: ["m7i.8xlarge", "m6i.8xlarge", "r7i.8xlarge", "r6i.8xlarge"]
    Default: "r6i.8xlarge"

  ConfigurationPattern:
    Description: Select the data protection method and the number of storage nodes
    Type: String
    AllowedValues: [
      "Mirroring Duplication ( 3 Nodes )",
      "Mirroring Duplication ( 6 Nodes )",
      "Mirroring Duplication ( 9 Nodes )",
      "Mirroring Duplication ( 12 Nodes )",
      "Mirroring Duplication ( 15 Nodes )",
      "Mirroring Duplication ( 18 Nodes )",
      "HPEC 4D+2P ( 6 Nodes )",
      "HPEC 4D+2P ( 12 Nodes )",
      "HPEC 4D+2P ( 18 Nodes )"]
    Default: "Mirroring Duplication ( 3 Nodes )"

  DriveCount:
    Description: Select the number of drives per storage node.
    Type: String
    AllowedValues: ["6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24"]
    Default: "6"

  PhysicalDriveCapacity:
    Description: Select the physical capacity per drive.
    Type: String
    AllowedValues: [
      "Mirroring Duplication 1579 GiB",
      "Mirroring Duplication 3155 GiB",
      "Mirroring Duplication 4730 GiB",
      "Mirroring Duplication 6405 GiB",
      "Mirroring Duplication 8473 GiB",
      "HPEC 4D+2P 1480 GiB",
      "HPEC 4D+2P 2661 GiB",
      "HPEC 4D+2P 3843 GiB",
      "HPEC 4D+2P 5025 GiB",
      "HPEC 4D+2P 6650 GiB"]
    Default: "Mirroring Duplication 1579 GiB"

  EbsVolumeEncryption:
    Description: Select enable or disable EBS encryption for VSP One SDS Block cluster.
    Type: String
    AllowedValues: ["disable", "enable"]
    Default: disable

  EbsVolumeKmsKeyId:
    Description: Enter the KMS Key ID if EbsVolumeEncryption is enable.
    Type: String
    Default: None

  TimeZone:
    Description: Select the time zone of VSP One SDS Block cluster.
    Type: String
    AllowedValues: [
        "Africa/Abidjan",
        "Africa/Accra",
        "Africa/Addis_Ababa",
        "Africa/Algiers",
        "Africa/Asmara",
        "Africa/Bamako",
        "Africa/Bangui",
        "Africa/Banjul",
        "Africa/Bissau",
        "Africa/Blantyre",
        "Africa/Brazzaville",
        "Africa/Bujumbura",
        "Africa/Cairo",
        "Africa/Casablanca",
        "Africa/Ceuta",
        "Africa/Conakry",
        "Africa/Dakar",
        "Africa/Dar_es_Salaam",
        "Africa/Djibouti",
        "Africa/Douala",
        "Africa/El_Aaiun",
        "Africa/Freetown",
        "Africa/Gaborone",
        "Africa/Harare",
        "Africa/Johannesburg",
        "Africa/Juba",
        "Africa/Kampala",
        "Africa/Khartoum",
        "Africa/Kigali",
        "Africa/Kinshasa",
        "Africa/Lagos",
        "Africa/Libreville",
        "Africa/Lome",
        "Africa/Luanda",
        "Africa/Lubumbashi",
        "Africa/Lusaka",
        "Africa/Malabo",
        "Africa/Maputo",
        "Africa/Maseru",
        "Africa/Mbabane",
        "Africa/Mogadishu",
        "Africa/Monrovia",
        "Africa/Nairobi",
        "Africa/Ndjamena",
        "Africa/Niamey",
        "Africa/Nouakchott",
        "Africa/Ouagadougou",
        "Africa/Porto-Novo",
        "Africa/Sao_Tome",
        "Africa/Tripoli",
        "Africa/Tunis",
        "Africa/Windhoek",
        "America/Adak",
        "America/Anchorage",
        "America/Anguilla",
        "America/Antigua",
        "America/Araguaina",
        "America/Argentina/Buenos_Aires",
        "America/Argentina/Catamarca",
        "America/Argentina/Cordoba",
        "America/Argentina/Jujuy",
        "America/Argentina/La_Rioja",
        "America/Argentina/Mendoza",
        "America/Argentina/Rio_Gallegos",
        "America/Argentina/Salta",
        "America/Argentina/San_Juan",
        "America/Argentina/San_Luis",
        "America/Argentina/Tucuman",
        "America/Argentina/Ushuaia",
        "America/Aruba",
        "America/Asuncion",
        "America/Atikokan",
        "America/Bahia",
        "America/Bahia_Banderas",
        "America/Barbados",
        "America/Belem",
        "America/Belize",
        "America/Blanc-Sablon",
        "America/Boa_Vista",
        "America/Bogota",
        "America/Boise",
        "America/Cambridge_Bay",
        "America/Campo_Grande",
        "America/Cancun",
        "America/Caracas",
        "America/Cayenne",
        "America/Cayman",
        "America/Chicago",
        "America/Chihuahua",
        "America/Costa_Rica",
        "America/Creston",
        "America/Cuiaba",
        "America/Curacao",
        "America/Danmarkshavn",
        "America/Dawson",
        "America/Dawson_Creek",
        "America/Denver",
        "America/Detroit",
        "America/Dominica",
        "America/Edmonton",
        "America/Eirunepe",
        "America/El_Salvador",
        "America/Fort_Nelson",
        "America/Fortaleza",
        "America/Glace_Bay",
        "America/Godthab",
        "America/Goose_Bay",
        "America/Grand_Turk",
        "America/Grenada",
        "America/Guadeloupe",
        "America/Guatemala",
        "America/Guayaquil",
        "America/Guyana",
        "America/Halifax",
        "America/Havana",
        "America/Hermosillo",
        "America/Indiana/Indianapolis",
        "America/Indiana/Knox",
        "America/Indiana/Marengo",
        "America/Indiana/Petersburg",
        "America/Indiana/Tell_City",
        "America/Indiana/Vevay",
        "America/Indiana/Vincennes",
        "America/Indiana/Winamac",
        "America/Inuvik",
        "America/Iqaluit",
        "America/Jamaica",
        "America/Juneau",
        "America/Kentucky/Louisville",
        "America/Kentucky/Monticello",
        "America/Kralendijk",
        "America/La_Paz",
        "America/Lima",
        "America/Los_Angeles",
        "America/Lower_Princes",
        "America/Maceio",
        "America/Managua",
        "America/Manaus",
        "America/Marigot",
        "America/Martinique",
        "America/Matamoros",
        "America/Mazatlan",
        "America/Menominee",
        "America/Merida",
        "America/Metlakatla",
        "America/Mexico_City",
        "America/Miquelon",
        "America/Moncton",
        "America/Monterrey",
        "America/Montevideo",
        "America/Montserrat",
        "America/Nassau",
        "America/New_York",
        "America/Nipigon",
        "America/Nome",
        "America/Noronha",
        "America/North_Dakota/Beulah",
        "America/North_Dakota/Center",
        "America/North_Dakota/New_Salem",
        "America/Ojinaga",
        "America/Panama",
        "America/Pangnirtung",
        "America/Paramaribo",
        "America/Phoenix",
        "America/Port-au-Prince",
        "America/Port_of_Spain",
        "America/Porto_Velho",
        "America/Puerto_Rico",
        "America/Punta_Arenas",
        "America/Rainy_River",
        "America/Rankin_Inlet",
        "America/Recife",
        "America/Regina",
        "America/Resolute",
        "America/Rio_Branco",
        "America/Santarem",
        "America/Santiago",
        "America/Santo_Domingo",
        "America/Sao_Paulo",
        "America/Scoresbysund",
        "America/Sitka",
        "America/St_Barthelemy",
        "America/St_Johns",
        "America/St_Kitts",
        "America/St_Lucia",
        "America/St_Thomas",
        "America/St_Vincent",
        "America/Swift_Current",
        "America/Tegucigalpa",
        "America/Thule",
        "America/Thunder_Bay",
        "America/Tijuana",
        "America/Toronto",
        "America/Tortola",
        "America/Vancouver",
        "America/Whitehorse",
        "America/Winnipeg",
        "America/Yakutat",
        "America/Yellowknife",
        "Antarctica/Casey",
        "Antarctica/Davis",
        "Antarctica/DumontDUrville",
        "Antarctica/Macquarie",
        "Antarctica/Mawson",
        "Antarctica/McMurdo",
        "Antarctica/Palmer",
        "Antarctica/Rothera",
        "Antarctica/Syowa",
        "Antarctica/Troll",
        "Antarctica/Vostok",
        "Arctic/Longyearbyen",
        "Asia/Aden",
        "Asia/Almaty",
        "Asia/Amman",
        "Asia/Anadyr",
        "Asia/Aqtau",
        "Asia/Aqtobe",
        "Asia/Ashgabat",
        "Asia/Atyrau",
        "Asia/Baghdad",
        "Asia/Bahrain",
        "Asia/Baku",
        "Asia/Bangkok",
        "Asia/Barnaul",
        "Asia/Beijing",
        "Asia/Beirut",
        "Asia/Bishkek",
        "Asia/Brunei",
        "Asia/Chita",
        "Asia/Choibalsan",
        "Asia/Colombo",
        "Asia/Damascus",
        "Asia/Dhaka",
        "Asia/Dili",
        "Asia/Dubai",
        "Asia/Dushanbe",
        "Asia/Famagusta",
        "Asia/Gaza",
        "Asia/Hebron",
        "Asia/Ho_Chi_Minh",
        "Asia/Hong_Kong",
        "Asia/Hovd",
        "Asia/Irkutsk",
        "Asia/Jakarta",
        "Asia/Jayapura",
        "Asia/Jerusalem",
        "Asia/Kabul",
        "Asia/Kamchatka",
        "Asia/Karachi",
        "Asia/Kathmandu",
        "Asia/Khandyga",
        "Asia/Kolkata",
        "Asia/Krasnoyarsk",
        "Asia/Kuala_Lumpur",
        "Asia/Kuching",
        "Asia/Kuwait",
        "Asia/Macau",
        "Asia/Magadan",
        "Asia/Makassar",
        "Asia/Manila",
        "Asia/Muscat",
        "Asia/Nicosia",
        "Asia/Novokuznetsk",
        "Asia/Novosibirsk",
        "Asia/Omsk",
        "Asia/Oral",
        "Asia/Phnom_Penh",
        "Asia/Pontianak",
        "Asia/Pyongyang",
        "Asia/Qatar",
        "Asia/Qyzylorda",
        "Asia/Riyadh",
        "Asia/Sakhalin",
        "Asia/Samarkand",
        "Asia/Seoul",
        "Asia/Shanghai",
        "Asia/Singapore",
        "Asia/Srednekolymsk",
        "Asia/Taipei",
        "Asia/Tashkent",
        "Asia/Tbilisi",
        "Asia/Tehran",
        "Asia/Thimphu",
        "Asia/Tokyo",
        "Asia/Tomsk",
        "Asia/Ulaanbaatar",
        "Asia/Urumqi",
        "Asia/Ust-Nera",
        "Asia/Vientiane",
        "Asia/Vladivostok",
        "Asia/Yakutsk",
        "Asia/Yangon",
        "Asia/Yekaterinburg",
        "Asia/Yerevan",
        "Atlantic/Azores",
        "Atlantic/Bermuda",
        "Atlantic/Canary",
        "Atlantic/Cape_Verde",
        "Atlantic/Faroe",
        "Atlantic/Madeira",
        "Atlantic/Reykjavik",
        "Atlantic/South_Georgia",
        "Atlantic/St_Helena",
        "Atlantic/Stanley",
        "Australia/Adelaide",
        "Australia/Brisbane",
        "Australia/Broken_Hill",
        "Australia/Currie",
        "Australia/Darwin",
        "Australia/Eucla",
        "Australia/Hobart",
        "Australia/Lindeman",
        "Australia/Lord_Howe",
        "Australia/Melbourne",
        "Australia/Perth",
        "Australia/Sydney",
        "Europe/Amsterdam",
        "Europe/Andorra",
        "Europe/Astrakhan",
        "Europe/Athens",
        "Europe/Belgrade",
        "Europe/Berlin",
        "Europe/Bratislava",
        "Europe/Brussels",
        "Europe/Bucharest",
        "Europe/Budapest",
        "Europe/Busingen",
        "Europe/Chisinau",
        "Europe/Copenhagen",
        "Europe/Dublin",
        "Europe/Gibraltar",
        "Europe/Guernsey",
        "Europe/Helsinki",
        "Europe/Isle_of_Man",
        "Europe/Istanbul",
        "Europe/Jersey",
        "Europe/Kaliningrad",
        "Europe/Kiev",
        "Europe/Kirov",
        "Europe/Lisbon",
        "Europe/Ljubljana",
        "Europe/London",
        "Europe/Luxembourg",
        "Europe/Madrid",
        "Europe/Malta",
        "Europe/Mariehamn",
        "Europe/Minsk",
        "Europe/Monaco",
        "Europe/Moscow",
        "Europe/Oslo",
        "Europe/Paris",
        "Europe/Podgorica",
        "Europe/Prague",
        "Europe/Riga",
        "Europe/Rome",
        "Europe/Samara",
        "Europe/San_Marino",
        "Europe/Sarajevo",
        "Europe/Saratov",
        "Europe/Simferopol",
        "Europe/Skopje",
        "Europe/Sofia",
        "Europe/Stockholm",
        "Europe/Tallinn",
        "Europe/Tirane",
        "Europe/Ulyanovsk",
        "Europe/Uzhgorod",
        "Europe/Vaduz",
        "Europe/Vatican",
        "Europe/Vienna",
        "Europe/Vilnius",
        "Europe/Volgograd",
        "Europe/Warsaw",
        "Europe/Zagreb",
        "Europe/Zaporozhye",
        "Europe/Zurich",
        "Indian/Antananarivo",
        "Indian/Chagos",
        "Indian/Christmas",
        "Indian/Cocos",
        "Indian/Comoro",
        "Indian/Kerguelen",
        "Indian/Mahe",
        "Indian/Maldives",
        "Indian/Mauritius",
        "Indian/Mayotte",
        "Indian/Reunion",
        "Pacific/Apia",
        "Pacific/Auckland",
        "Pacific/Bougainville",
        "Pacific/Chatham",
        "Pacific/Chuuk",
        "Pacific/Easter",
        "Pacific/Efate",
        "Pacific/Enderbury",
        "Pacific/Fakaofo",
        "Pacific/Fiji",
        "Pacific/Funafuti",
        "Pacific/Galapagos",
        "Pacific/Gambier",
        "Pacific/Guadalcanal",
        "Pacific/Guam",
        "Pacific/Honolulu",
        "Pacific/Kiritimati",
        "Pacific/Kosrae",
        "Pacific/Kwajalein",
        "Pacific/Majuro",
        "Pacific/Marquesas",
        "Pacific/Midway" ,
        "Pacific/Nauru",
        "Pacific/Niue",
        "Pacific/Norfolk",
        "Pacific/Noumea",
        "Pacific/Pago_Pago",
        "Pacific/Palau",
        "Pacific/Pitcairn",
        "Pacific/Pohnpei",
        "Pacific/Port_Moresby",
        "Pacific/Rarotonga",
        "Pacific/Saipan",
        "Pacific/Tahiti",
        "Pacific/Tarawa",
        "Pacific/Tongatapu",
        "Pacific/Wake",
        "Pacific/Wallis",
        "UTC"
    ]
    Default: "UTC"

  BillingCode:
    Description: Enter the cost monitoring code for VSP One SDS Block.
    Type: String
    Default: VSPOneSDSBlock

  S3URI:
    Description: Enter the S3 folder (in URI format) where error message files are to be output during installation.
    Type: String
    Default: s3://bucket/folder/

  IamRoleNameForStorageCluster:
    Description: Enter the IAM role name for VSP One SDS Block cluster.
    Type: String

Metadata:
  AWS::CloudFormation::Interface:
    ParameterGroups:
      -
        Label:
          default: Cluster Configuration
        Parameters:
          - ClusterName
          - AvailabilityZone
          - VpcId
          - ControlSubnetId
          - ControlNetworkCidrBlock
          - InterNodeSubnetId
          - ComputeSubnetId
          - ComputeIpVersion
          - StorageNodeInstanceType
          - ConfigurationPattern
          - DriveCount
          - PhysicalDriveCapacity
          - EbsVolumeEncryption
          - EbsVolumeKmsKeyId
          - TimeZone
          - BillingCode
          - S3URI
          - IamRoleNameForStorageCluster

Mappings:
  VssbApAmi:
    us-east-1:
      Value: ami-0e082fa0a7b81c596
    us-east-2:
      Value: ami-0973d891292b55449
    us-west-1:
      Value: ami-052bf7ce53fa67e7a
    us-west-2:
      Value: ami-06093c132f7a3a9b6
    ca-central-1:
      Value: ami-07ccdde403b76d53b
    eu-north-1:
      Value: ami-0905c633d806f478e
    eu-central-1:
      Value: ami-00e392858a5491c4c
    eu-south-1:
      Value: ami-0ff0d9f586810efea
    eu-west-1:
      Value: ami-0a00d26b4a6ff629f
    eu-west-2:
      Value: ami-066620a8c1651db62
    ap-southeast-2:
      Value: ami-0fd013241e10290d7
    ap-northeast-1:
      Value: ami-0f971678e41b9efbe
    ap-northeast-2:
      Value: ami-093be369c3d3f29f5
    ap-northeast-3:
      Value: ami-059147661a18feea3

  Template:
    Version:
      Data: 01.17.00.30

# ----------------------------------------------------------------
#     Resources
# Define the settings for the resource to be created.
# ----------------------------------------------------------------

Resources:

  # ---------- Cluster stack definitions start here. ----------

  StorageClusterDuplication:
    Type: AWS::CloudFormation::Stack
    Condition: StorageClusterDuplicationCreate
    Properties:
      TemplateURL: "https://s3.amazonaws.com/awsmp-fulfillment-cf-templates-prod/d5ee2dc6-a777-40a4-b15d-ae4a4671f843.cd29e0e9-61b0-4b32-b802-454c77a6f835.VMConfigurationFile_Duplication_BYOL_nested1.yml"
      Parameters:
        LicenseType: BYOL
        StorageNodeStackName: {"Ref": AWS::StackName}
        VpcId: {"Ref": VpcId}
        AvailabilityZone: {"Ref": AvailabilityZone}
        TimeZone: {"Ref": TimeZone}
        ControlSubnetId: {"Ref": ControlSubnetId}
        ControlNetworkCidrBlock: {"Ref": ControlNetworkCidrBlock}
        InterNodeSubnetId: {"Ref": InterNodeSubnetId}
        ComputeSubnetId: {"Ref": ComputeSubnetId}
        ComputeIpVersion: {"Ref": ComputeIpVersion}
        StorageNodeInstanceType: {"Ref": StorageNodeInstanceType}
        BillingCode: {"Ref": BillingCode}
        ClusterName: {"Ref": ClusterName}
        NodeCount: {"Fn::Select": ["3", "Fn::Split": [" ", "Ref": ConfigurationPattern]]}
        DriveCount: {"Ref": DriveCount}
        DriveSize: {"Fn::Select": ["2", "Fn::Split": [" ", "Ref": PhysicalDriveCapacity]]}
        EbsVolumeEncryption: {"Ref": EbsVolumeEncryption}
        EbsVolumeKmsKeyId: {"Ref": EbsVolumeKmsKeyId}
        IamRoleNameForStorageCluster: {"Ref": IamRoleNameForStorageCluster}
        DisableNodeTerminationProtection: "-"
        RemoveNodeNumber: "-"
        RecoverNodeNumber: "-"
        RemoveDriveNodeNumber: "-"
        RemoveDriveNumber: "-"
        StorageNodeAMIId01: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId02: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId03: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId04: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId05: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId06: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId07: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId08: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId09: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId10: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId11: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId12: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId13: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId14: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId15: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId16: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId17: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId18: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}

  StorageCluster4D2P:
    Type: AWS::CloudFormation::Stack
    Condition: StorageCluster4D2PCreate
    Properties:
      TemplateURL: "https://s3.amazonaws.com/awsmp-fulfillment-cf-templates-prod/d5ee2dc6-a777-40a4-b15d-ae4a4671f843.cd29e0e9-61b0-4b32-b802-454c77a6f835.VMConfigurationFile_4D2P_BYOL_nested1.yml"
      Parameters:
        LicenseType: BYOL
        StorageNodeStackName: {"Ref": AWS::StackName}
        VpcId: {"Ref": VpcId}
        AvailabilityZone: {"Ref": AvailabilityZone}
        TimeZone: {"Ref": TimeZone}
        ControlSubnetId: {"Ref": ControlSubnetId}
        ControlNetworkCidrBlock: {"Ref": ControlNetworkCidrBlock}
        InterNodeSubnetId: {"Ref": InterNodeSubnetId}
        ComputeSubnetId: {"Ref": ComputeSubnetId}
        ComputeIpVersion: {"Ref": ComputeIpVersion}
        StorageNodeInstanceType: {"Ref": StorageNodeInstanceType}
        BillingCode: {"Ref": BillingCode}
        ClusterName: {"Ref": ClusterName}
        NodeCount: {"Fn::Select": ["3", "Fn::Split": [" ", "Ref": ConfigurationPattern]]}
        DriveCount: {"Ref": DriveCount}
        DriveSize: {"Fn::Select": ["2", "Fn::Split": [" ", "Ref": PhysicalDriveCapacity]]}
        EbsVolumeEncryption: {"Ref": EbsVolumeEncryption}
        EbsVolumeKmsKeyId: {"Ref": EbsVolumeKmsKeyId}
        IamRoleNameForStorageCluster: {"Ref": IamRoleNameForStorageCluster}
        DisableNodeTerminationProtection: "-"
        RemoveNodeNumber: "-"
        RecoverNodeNumber: "-"
        RemoveDriveNodeNumber: "-"
        RemoveDriveNumber: "-"
        StorageNodeAMIId01: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId02: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId03: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId04: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId05: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId06: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId07: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId08: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId09: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId10: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId11: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId12: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId13: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId14: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId15: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId16: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId17: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}
        StorageNodeAMIId18: {"Fn::FindInMap": [VssbApAmi, "Ref": 'AWS::Region', Value]}

  # ---------- Cluster stack definitions end here. ----------

  # ---------- Output definitions start here. ----------

Outputs: 
    TemplateVersion: 
        Value: {"Fn::FindInMap": ["Template", "Version", "Data"]} 
    InstallationStatus: 
        Value: Completed
        Description: The status of the installation.

    Configuration:
        Value: {"Fn::If": [StorageCluster4D2PCreate, "HPEC 4D+2P", {"Fn::If": [StorageClusterDuplicationCreate, "Mirroring Duplication", "Configuration Error"]}]}

  # ---------- Output definitions end here. ----------



EOT
  parameters = {
    ClusterName                  = var.cluster_name
    AvailabilityZone             = var.availability_zone
    VpcId                        = var.vpc_id
    ControlSubnetId              = var.control_subnet_id
    ControlNetworkCidrBlock      = data.aws_subnet.control_subnet.cidr_block
    InterNodeSubnetId            = var.internode_subnet_id
    ComputeSubnetId              = var.compute_subnet_id
    StorageNodeInstanceType      = var.storage_node_instance_type
    ConfigurationPattern         = var.configuration_pattern
    DriveCount                   = var.drive_count
    PhysicalDriveCapacity        = var.physical_drive_capacity
    EbsVolumeEncryption          = var.ebs_volume_encryption
    EbsVolumeKmsKeyId            = var.ebs_volume_kms_key_id
    TimeZone                     = var.time_zone
    BillingCode                  = var.billing_code
    S3URI                        = var.s3_uri
    IamRoleNameForStorageCluster = var.iam_role_name
  }
  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]
  on_failure   = "DELETE"
}
data "aws_lb" "lb" {
  name       = "${var.cluster_name}-ELB"
  depends_on = [aws_cloudformation_stack.parent_stack]
}


data "aws_security_group" "control_sg" {
  filter {
    name   = "tag:Name"
    values = ["${var.cluster_name}_ControlSecurityGroup"]
  }
  depends_on = [aws_cloudformation_stack.parent_stack]
}


resource "aws_security_group_rule" "allow_jump_tcp" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [var.jmp_host_ip]
  security_group_id = data.aws_security_group.control_sg.id
}

resource "time_sleep" "wait_30_minutes_before_python" {
  depends_on = [aws_cloudformation_stack.parent_stack]
  create_duration = "40m"
}
resource "null_resource" "run_passwordreset_local" {
  depends_on = [time_sleep.wait_30_minutes_before_python]

  provisioner "local-exec" {
    command = <<EOT
      echo Waiting 8 minutes for SDS Block cluster initialization...
      sleep 60
      echo Running SDS password reset script locally...
      python3 ${path.module}/password_reset.py \
  --sdsc-endpoint "https://${data.aws_lb.lb.dns_name}" \
  --current-password "${var.sds_default_password}" \
  --new-password "${var.sds_new_password}" > ${path.module}/sdsc_password_reset.log 2>&1
    EOT
  }
}

# ---------------------------------------------------------------------------
# Run Ansible playbook ~8 minutes after SDS Block cluster deployment
# ---------------------------------------------------------------------------
resource "null_resource" "run_ansible_expand_pool" {
  depends_on = [
    null_resource.run_passwordreset_local

  ]

  provisioner "local-exec" {
    command = <<EOT
      
  

      echo "Running Ansible playbook to expand storage pool..."
      ansible-playbook ./ansible/storage_pool.yml \
        -i localhost, \
        --extra-vars "storage_address=${data.aws_lb.lb.dns_name} storage_username=admin storage_password=var.sds_new_password"
    EOT
  }
}

# Allow ROSA Worker Nodes to access SDS API (443)
resource "aws_security_group_rule" "allow_rosa_to_sds_api" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.rosa_subnet_cidr]
  security_group_id = data.aws_security_group.control_sg.id
  description       = "Allow ROSA workers to access SDS API endpoint (443)"
}

# Allow ROSA Worker Nodes iSCSI access (3260)
resource "aws_security_group_rule" "allow_rosa_to_sds_iscsi" {
  type              = "ingress"
  from_port         = 3260
  to_port           = 3260
  protocol          = "tcp"
  cidr_blocks       = [var.rosa_subnet_cidr]
  security_group_id = data.aws_security_group.control_sg.id
  description       = "Allow ROSA workers iSCSI access to SDS storage (TCP 3260)"
}



