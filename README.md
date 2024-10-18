
- [RCS Co. Ltd. DevOps Engineer Hiring Challenge](#rcs-co-ltd-devops-engineer-hiring-challenge)
  - [Description](#description)
    - [Repository structure](#repository-structure)
      - [Node.js application](#nodejs-application)
      - [Dockerfile](#dockerfile)
      - [Terraform configuration](#terraform-configuration)
      - [Helm configuration](#helm-configuration)
      - [GitHub Workflow](#github-workflow)
    - [Prerequisites](#prerequisites)
    - [Deployment](#deployment)
  - [Testing](#testing)
    - [Testing the application remotely](#testing-the-application-remotely)
    - [Testing the application locally](#testing-the-application-locally)

# RCS Co. Ltd. DevOps Engineer Hiring Challenge

## Description

This project is a Proof of Concept (POC) to demonstrate the deployment of a Node.js application with an SQLite database on an Azure Kubernetes Service (AKS) cluster. The deployment is automated using Terraform to configure the infrastructure, Helm to manage the Kubernetes resources, and GitHub Actions to automate CI/CD processes.

### Repository structure

````bash
# Repository structure
.
├── app/                    # Contains the Node.js application
├── Dockerfile              # Dockerfile to build the Node.js application image
├── .github
│   └── workflows/          # Contains GitHub Actions workflow for CI/CD
├── helm-config/            # Contains Helm chart for deploying the Node.js app on Kubernetes
├── README.md
└── terraform-config/       # Contains Terraform files for provisioning Azure infrastructure
````

#### Node.js application

The `app/` directory contains a simple Node.js application with functionality to add new users and view the list of existing users. The application uses the Express framework for handling HTTP requests and SQLite as the database to store user information (name and email). It is containerized using Docker.


#### Dockerfile

The Dockerfile builds and runs the Node.js application.

#### Terraform configuration

Terraform configuration files under `terraform-config/` automate the setup of infrastructure on Azure, including backend storage for state management, resource groups, a virtual networks with a subnet, and AKS cluster.

#### Helm configuration

The Helm chart defines the deployment and service configuration for the containerized Node.js application. It creates a Kubernetes Deployment to manage the application, setting replicas, labels, and environment variables, and specifying the container image to use.

#### GitHub Workflow

The GitHub Actions workflow automates the deployment of the Node.js application to AKS. It sets up Azure resources using Terraform, including storage accounts and resource groups if they do not already exist. The workflow then deploys Kubernetes resources via Helm, ensuring the application is properly configured on the AKS cluster. After deployment, it retrieves the external IP address of the application and verifies its status by checking the service's readiness and accessibility.

### Prerequisites

1. [Microsoft Azure account](https://azure.microsoft.com/en-us/get-started/azure-portal)

2. [AzureCLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli#install) installed.

### Deployment

> ⚠️ Important Note
>
> To automate the deployment process, the environment variables are used within the GitHub Actions workflow. These variables include Azure authentication details. Make sure to configure them before triggering the deployment.
>
> Add the following secrets to your GitHub repository:
> 
> * `AZURE_SUBSCRIPTION_ID`: The ID of your Azure subscription.
> * `AZURE_CREDENTIALS`: The JSON output from creating the Azure Service Principal, containing all necessary authentication details.
> * `AZURE_CLIENT_ID`: The client ID from your Azure Service Principal.
> * `AZURE_CLIENT_SECRET`: The client secret from your Azure Service Principal.
> * `AZURE_SUBSCRIPTION_ID`: The ID of your Azure subscription.
> * `AZURE_TENANT_ID`: The tenant ID associated with your Azure account.
>
> Ensure that all secrets are created in your GitHub repository with the exact names specified. The workflow relies on these names to properly access and utilize the secrets during the deployment process.

1. Create a new public repository on [Github](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository).


2. Login to Azure abd retrieve your subscription ID:

    ````bash
    az login
    az account show --query id --output tsv

    XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
    ````

4. Add the Azure subscription ID to [GitHub secrets](https://docs.github.com/ru/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-a-repository) as `AZURE_SUBSCRIPTION_ID`.

5. Create a service principal:

    ````bash
    az ad sp create-for-rbac --name "SERVICE_PRINCIPAL_NAME" --role Contributor --scopes /subscriptions/AZURE_SUBSCRIPTION_ID --sdk-auth

    {
    "clientId": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
    "clientSecret": "XXXXX~XXXX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    "subscriptionId": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXX",
    "tenantId": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
    "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
    "resourceManagerEndpointUrl": "https://management.azure.com/",
    "activeDirectoryGraphResourceId": "https://graph.windows.net/",
    "sqlManagementEndpointUrl": "https://management.core.windows.net:XXXX/",
    "galleryEndpointUrl": "https://gallery.azure.com/",
    "managementEndpointUrl": "https://management.core.windows.net/"
    }
    ````

6. Add the output from the service principal creation to [GitHub secrets](https://docs.github.com/ru/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-a-repository) as `AZURE_CREDENTIALS`.

7. Add the `clientId` to [GitHub secrets](https://docs.github.com/ru/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-a-repository) as `AZURE_CLIENT_ID`.

8. Add `clientSecret` to [GitHub secrets](https://docs.github.com/ru/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-a-repository) as `AZURE_CLIENT_SECRET`.

9. Add the `tenantId` to [GitHub secrets](https://docs.github.com/ru/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-a-repository) as `AZURE_TENANT_ID`.

10. Navigate to the `valeeva.levi` directory:

    ````bash
    cd valeeva.levi
    ````

11. Add locally hosted code to GitHub:

    ````bash
    git init
    git add .
    git commit -m "Initial commit"
    git branch -M main
    git remote add origin git@github.com:GIT_USERNAME/REPOSITORY_NAME.git
    git push -u origin main
    ````

## Testing

### Testing the application remotely

1. Once the CI/CD pipeline has successfully completed, retreive the external IP for the application:

    ```bash
    az aks get-credentials --resource-group XYZResourceGroup --name XYZCluster
    kubectl get service poc-abc-service --output jsonpath="{.status.loadBalancer.ingress[0].ip}"

    XX.XXX.XX.XX
    ````

2. Access the application in your browser via `http://XX.XXX.XX.XX/`

### Testing the application locally

1. Install the dependencies and run the application:

````bash
cd app/
npm install
node app.js

App is running on http://localhost:3000
````

1. Access the application in your browser via `http://localhost:3000`