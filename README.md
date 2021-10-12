# Qualys IaC GitHub Action


## Description
Qualys IaC GitHub action is used to scan the Infrastructure-as-Code templates in your GitHub repository using Qualys CloudView (Cloud Security Assessment). It checks for security issues using the Qualys Cloud Infrastructure as Code Scan and displays the failed checks as pipeline annotations.

Note: Qualys IaC GitHub action supports below file formats for scanning.
* Terraform supported extensions: `.tf`, `.json`
* CloudFormation supported extensions: `.template`, `.yml`, `.yaml`


## How to use the Qualys IaC GitHub Action

1. Visit [GitHub configuration a workflow](https://help.github.com/en/actions/configuring-and-managing-workflows/configuring-a-workflow) to enable Github Action in your repository.
2. Subscribe to Qualys CloudView and obtain Qualys credentials.
3. Create GitHub Secrets for Qualys URL, Qualys Username and Qualys Password.
Refer to [Encrypted secrets](https://docs.github.com/en/actions/reference/encrypted-secrets) for more details on how to setup secrets.
4. Configure your workflow. In the actions section use `QIntegration/github_action_qiac@main`
Note: the `actions/checkout` step is required to run before the scan action, otherwise the action does not have access to the IaC files to be scanned.
5. Optionally, supply parameters to customize GitHub action behaviour.

## Usage Examples

### Scan IaC in your repository on push event
Note: In case of `push` event, the scan scope will be limited to the changed or newly added files only. This is to avoid the unnecessary scanning of files which are not part of this push event.
```yaml
name: Qualys IAC Scan 
on:
  push:
    branches:
      - main
jobs:
    Qualys_iac_scan:
        runs-on: ubuntu-latest
        name: Qualys IaC Scan
        steps:
          - name: Checkout
            uses: actions/checkout@v2 
            with:
                fetch-depth: 0
    
          - name: Qualys IAC scan action step
            uses: QIntegration/github_action_qiac@main
            id: qiac
            env:
                URL: ${{ secrets.URL }}
                UNAME: ${{ secrets.USERNAME }}
                PASS: ${{ secrets.PASSWORD }}
```

### Scan IaC in your repository on pull request event
Note: In case of `pull request` event, the scope of scan will be limited to the files included in the pull request only. This is to avoid the unnecessary scanning of files which are not part of this pull request.
```yaml
name: Qualys IAC Scan 
on:
  pull_request:
    branches:
      - main 
jobs:
    Qualys_iac_scan:
        runs-on: ubuntu-latest
        name: Qualys IaC Scan
        steps:
          - name: Checkout
            uses: actions/checkout@v2 
            with:
                fetch-depth: 0
    
          - name: Qualys IAC scan action step
            uses: QIntegration/github_action_qiac@main
            id: qiac
            env:
                URL: ${{ secrets.URL }}
                UNAME: ${{ secrets.USERNAME }}
                PASS: ${{ secrets.PASSWORD }}
```

### Scan IaC in your repository on scheduled event
Note: In case of `scheduled` event, the path given in `directory` input will be scanned. In case the path is not given, the **entire repository** will be scanned.
```yaml
name: Qualys IAC Scan 
on:
  schedule:
    - cron:  '*/5 * * * *'
jobs:
    Qualys_iac_scan:
        runs-on: ubuntu-latest
        name: Qualys IaC Scan
        steps:
          - name: Checkout
            uses: actions/checkout@v2 
            with:
                fetch-depth: 0
    
          - name: Qualys IAC scan action step
            uses: QIntegration/github_action_qiac@main
            id: qiac
            env:
                URL: ${{ secrets.URL }}
                UNAME: ${{ secrets.USERNAME }}
                PASS: ${{ secrets.PASSWORD }}
            with:
              directory: 'path of directory to scan (optional)'
```

### Scan IaC in your repository on manual trigger
Note: In case of `workflow_dispatch` event or manual trigger, the path given in `directory` input will be scanned. In case the path is not given, the `entire repository` will be scanned.
```yaml
name: Qualys IAC Scan 
on: workflow_dispatch
jobs:
    Qualys_iac_scan:
        runs-on: ubuntu-latest
        name: Qualys IaC Scan
        steps:
          - name: Checkout
            uses: actions/checkout@v2 
            with:
                fetch-depth: 0
    
          - name: Qualys IAC scan action step
            uses: QIntegration/github_action_qiac@main
            id: qiac
            env:
                URL: ${{ secrets.URL }}
                UNAME: ${{ secrets.USERNAME }}
                PASS: ${{ secrets.PASSWORD }}
            with:
              directory: 'path of directory to scan (optional)'
```

## Prerequisites for Qualys IaC GithHub Action
1. Valid Qualys Credentials and subscription of Qualys CloudView module.
2. Use of `actions/checkout@v2` with ` fetch-depth: 0` before calling Qualys IaC GitHub action.
3. `Qualys URL, Qualys Username , Qualys Password` to be added in `secrets` and provided as `environment variables` to the Qualys IaC GitHub action.
4. Self-hosted runners must use a Linux operating system and have Docker installed to run this action.

## GitHub action Parameters

| Parameter  | Description | Required | Default | Type |
| -----------| -------------------------------------------------------------------------------------------------------- | ------------- | ------------- | ------------- |
| directory | IaC root directory to scan.  If not provided then entire repository will be scanned in case of manual or scheduled action trigger  | No | "." | Input parameter |
