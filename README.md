# Shadowise - Test a new release using real traffic

A script enabling traffic shadowing and response differences analysis for a new release (dark canary deployment) of an HTTP API.

The script modifies the `helm` folder of a repository so that there are two deployments present for the service - `primary/original` (with the name `your-service-orig`), and `candidate/shadow` (with the name `your-service-shadow`). The `primary` is an older version you want to compare your release with, while the `shadow` deployment will run the code from your new branch.
The job of traffic shadowing and response difference analysis is performed by a third deployment which is using a fork of [diferencia](https://github.com/lordofthejars/diferencia). A fork was needed because the original application has a bug causing duplicate "Content-Type" headers which break `api-policy-component`. `diferencia` forwards the traffic that is going to the service to both `primary` and `shadow`, returns the response from `primary` to the user, and compares the responses of the two deployments.
Any differences can be seen in the `diferencia` dashboard. To access it create a port-forward to the 8082 port of the `diferencia-your-service` pod and open `http://localhost:8082` in a web browser.

## Running

### Usage

```shell
./shadow_converter.sh [--promote-shadow] <original version tag>
```

### Step-by-step guide

1. Copy the Helm templates from the `templates` folder of this repository to the `helm/<your-repo>/templates` folder of the repository you want to test (using the branch you want to test).

1. Copy the `shadow_converter.sh` file from this repository to the base folder of your repository (using the branch you want to test).

1. Check the `primary` release which you want to compare your branch with, and write down the tag name.

1. Run the `shadow_converter.sh` script using that tag name as an argument, e.g.:

    ```shell
    chmod +x ./shadow_converter.sh

    # The default behaviour is to return to the user the response of the primary destination
    ./shadow_converter.sh v1.0.0

    # If you want to return to the user the response of your new release (e.g. for testing on Dev)
    # use the following command instead
    ./shadow_converter.sh --promote-shadow v1.0.0
    ```

1. Add the changes made by the script to the content staged for commit:

    ```shell
    git add helm
    ```

1. Commit and push to GitHub

    ```shell
    git commit -m "Shadowise"
    git push
    ```

1. Create a new release in your repo and release it as usual using Jenkins

1. Once deployed, you can check the new version for differences using the `diferencia` dashboard

    1. Port-forward to the `diferencia` pod for your service, e.g.:

        ```shell
        kubectl get pods | grep diferencia
        kubectl port-forward diferencia-public-concordances-api-74fc78d797-7wrfj 8082
        ```

    1. And then go to a web browser and open `http://localhost:8082/dashboard/`
