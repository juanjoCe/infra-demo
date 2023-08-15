# Azure Infrastructure

To enhance the management and maintainability of the Terraform code, the modules are organized in a dedicated folder. This enables the `main.tf` file to efficiently reuse the module code for provisioning the infrastructure.

## **Prerequisites**

- Install Azure CLI using the [Microsoft documentation](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest), in my case I used Brew to install the Azure CLI.

- In order to provision an AKS cluster, we need to have a **Service Principal**. In this way we can Authenticate with Azure an provision the resource. 

- Install `az aks install-cli` so we can work with the Kubernetes Cluster from our own terminal, or you can use it directly from the Azure Portal Terminal. 

---
## Steps

1- Create a Service Principal

- Once we are logged in using `az login`, the following information will be printed on screen. Make sure to take note of the "id" value.

![az-login-info](/infra-doc/az-login.png)

- With the given value, make sure to edit the following command in order to create the Service Principal: 

      az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" --name "ServicePrincipalName"

  Take note to the "appId" and "password" values:
  ![app-id](/infra-doc/app-id.png)

- Store the values in an Azure Key Vault to authenticate automatically when we are provisioning the AKS cluster. 

      az keyvault secret set --vault-name "<keyvault-name>" --name "spId" --value "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"

      az keyvault secret set --vault-name "<keyvault-name>" --name "spSecret" --value "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"

- To retreive the values without writing the "id" and "secret" values, we can use environment variables.

      TF_VAR_client_id=$(az keyvault secret show --name "serprinId" --vault-name "<keyvault-name>" --query value -o tsv)

      TF_VAR_client_secret=$(az keyvault secret show --name "serprinSecret" --vault-name "<keyvault-name>" --query value -o tsv)

      ARM_ACCESS_KEY=$(az keyvault secret show --name "tstateAKey" --vault-name "<keyvault-name>" --query value -o tsv)

2- Running `terraform init` and `terraform apply`

- On the **azure-infra** folder, we can review the `main.tf` file, which contains the Terraform Backend configured, in case you have a different parameters for your infra, you can moddify them for a propper custom deployment. 

- Navigate to the **azure-infra** folder: `cd azure-infra`, once we are in the folder, we can run the command `terraform init` so Terraform can start downloading the necessary files in order to execute the next commands. 

- We can use the `terraform plan` command in case we want to view the infrastructure plan.

- Once we are sure the infrastructure contains everything we want, we can execute `terraform apply`, once we are promted to confirm the desired infrastructure, proceed to type `yes` in the terminal. 

3- Deploying the apps in the Azure Kubernetes Cluster

- On the terminal, run the following command in order to connect to your Kubernetes Cluster, make sure to type your `resource group` and your `kluster name`:

      az aks get-credentials --resource-group myResourceGroup --name myAKSCluster

![az-get-cred](/infra-doc/az-get-cre.png)

  Now we can see that our cluster is running with the command `kubectl get nodes`.

- On the root folder **DEMO**, there is a folder named **deployment-apps**, this folder contains the Kubernetes manifests with a sample application we can use to run and test our cluster. 


  Using the command `kubectl apply -f deployment-apps`, the Kubernetes manifests will deploy the sample application. 
  We can view our pods using the command `kubectl get pods`, and view our services and the `external-ip` address using the command `kubectl get svc`.
![](/infra-doc/apply-f.png)

- In order to test the sample app, copy the `EXTERNAL-IP` address and paste it in your browser. 

![](/infra-doc/app-running.png)