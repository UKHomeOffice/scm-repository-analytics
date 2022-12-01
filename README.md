# scm-repository-analytics

## Getting started

### Install required dependencies

#### Install steampipe

```bash
brew tap turbot/tap
brew install steampipe
```

#### Install the Github plugin

```bash
steampipe plugin install github
```

Ensure you have a valid GitHub access token set in the `~/.steampipe/config/github.spc` file.

#### Clone the scm-repository-analytics repo locally

```bash
git clone https://github.com/UKHomeOffice/scm-repository-analytics.git
```

#### Move into the cloned repo and run the dashboard

```bash
cd scm-repository-analytics
steampipe dashboard
```

### Directory structure

```bash
.
├── LICENSE
├── README.md
├── controls
│   ├── issue.sp
│   ├── organization.sp
│   ├── private_repo.sp
│   └── public_repo.sp
├── dashboards
│   └── dashboard.sp
├── docs
│   └── index.md
└── mod.sp
```

**mod.sp**

Steampipe modification metadata file (may not be needed if not being published).

**./controls**

Contains configuration files for control checks written in HCL.

**./dashboards**

Contains configuration for dashboards for visualising queries and data, again written in HCL.

**./docs**

Modification documentation specific to the steampipe package.
