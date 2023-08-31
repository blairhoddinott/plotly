# Plotly Technical Assessment

## Overview

Tasked with the following objectives:
- build Dockerfile for this application
- build a deployment mechanic for this application

I have built a multistage Dockerfile for this application. I have modified the original application to streamline environment variables as well as bake in some defaults, so it doesn't crash if you don't provide the env vars. I also implemented gunicorn to run this in a production friendly way. Further, I needed to modify the flask version, as it was preventing UWSGI from building (1.0.3 -> 2.0.3)

For continuous delivery, I have chosen to use GitHub Actions for this. It provides the necessary functionality, feedback and community adoption. This means there are a lot of resources available should you wish to increase complexity, or run into problems.

## Environment Setup

### Kubernetes

For this test, I deployed a single node Kubernetes locally using k3s. I didn't do anything fancy, just got it up and running following [THEIR DOCS](https://docs.k3s.io/quick-start). I used the built-in traefik ingress to provide access to my container externally.


### GitHub Actions

To allow GitHub Actions to access my local resources, I elected to run a GitHub Actions Runner in my local environment. More documentation can be found [HERE](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners?learn=hosting_your_own_runners&learnProduct=actions), this was super straightforward. Once this was setup, I went into the settings of the Repository and added the runner.

While in the GitHub Repository Settings page, I also added the following Secrets:
- DOCKER_USERNAME
- DOCKER_PASSWORD
- KUBE_CONFIG

These are needed to log into my dockerhub account to push images, and to log into my k8s cluster, respectively. The KUBE_CONFIG was made viable by running this command:

```bash
cat ~/.kube/config | base64
```

### DockerHub

The next prereq that needed to be solved was adding the docker repository secrets to k8s so it can log into my account and pull the image. This would not be necessary if my image was set to public. 

In the k8s-prereqs directory, there is a file `userapi-dockerconfig-secret.yaml` that needs to be modified. 

From the k8s host, I ran the following:

```bash
docker login -u <username> -p <password>
cat ~/.docker/config.json | base64
```

Grabbing the base64, replace the `<REPLACE_ME>` section of `userapi-dockerconfig-secret.yaml` and then apply it to the cluster:

```bash
kubectl apply -f userapi-dockerconfig-secret.yaml
```

### Pipeline Customizations

In the GitHub actions, I have the job pushing to my repository (`weepyadmin/plotly`). This should be changed for your environemnt. Simply replace all `weepyadmin/plotly` with the appropriate docker login/image name of your choosing, and then you should be good to go.

Finally, in the file `userapi-ingress.yaml`, I have the FQDN for this container set to `userapi.weepytests.com`, which is what I was using for local testing. You will need to update this field (the `host` key) to the appropriate FQDN for your environment, so Traefik will route your traffic correctly.

When code is checked in, the pipeline fires, deploys the container, service, ingress. 

## Future Improvements

Right now, this will build on all pushes. Future steps would be to extend the pipeline to build prod branches out into a production-only cluster. 

I would also perhaps modify the pipeline so that it only builds out to dev cluster on a dev branch. This way all branches don't kick off and overwrite each other on the node. 

I would further ask that unit testing be included, then we can incorporate unit testing as a base step for any/all deployments, and all pushes. I would make the deployment dependent on Unit Tests passing for production at least, but likely for any deployment environment. 