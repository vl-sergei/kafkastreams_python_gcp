# M12_KafkaStreams_JVM_GCP
1) Create your own project on GCP (currently Google offers trial accounts up to 300$).
2) Install Google Cloud CLI (gcloud & gsutil), Kubernetes controls (kubectl) and spark on your host machine.
3) Use `gcloud auth login && gcloud auth application-default login && gcloud config set project [PROJECT]` to initialize access to your project.
4) Run `terraform init && terraform apply`. Provide your project ID and already **existing** bucket for Terraform state. Terraform script will create a K8S cluster, container registry, GCS bucket for the registry and a service account with RW permission for the Container Registry.
5) Run `gcloud container clusters get-credentials [CLUSTER_NAME] --zone [CLUSTER_ZONE] --project [PROJECT]` to configure kubectl to work with your k8s cluster.
6) After the task is done don't forget to `terraform destroy` your GCP resources.

# Kafka connect in Kubernetes

## Install Confluent Hub Client

You can find the installation manual [here](https://docs.confluent.io/home/connect/confluent-hub/client.html)

## Create a custom docker image

For running the GCS connector, you can create your own docker image. Create your GCS connector image and build it.

## Launch Confluent for Kubernetes

### Create a namespace

- Create the namespace to use:

  ```cmd
  kubectl create namespace confluent
  ```

- Set this namespace to default for your Kubernetes context:

  ```cmd
  kubectl config set-context --current --namespace confluent
  ```

### Install Confluent for Kubernetes

- Add the Confluent for Kubernetes Helm repository:

  ```cmd
  helm repo add confluentinc https://packages.confluent.io/helm
  helm repo update
  ```

- Install Confluent for Kubernetes:

  ```cmd
  helm upgrade --install confluent-operator confluentinc/confluent-for-kubernetes
  ```

## Create your own connector's image

- Create your own connector's docker image using provided Dockerfile and use it in confluent-platform.yaml

### Install Confluent Platform

- Install all Confluent Platform components:

  ```cmd
  kubectl apply -f ./confluent-platform.yaml
  ```

- Install a sample producer app and topic:

  ```cmd
  kubectl apply -f ./producer-app-data.yaml
  ```

- Check that everything is deployed:

  ```cmd
  kubectl get pods -o wide 
  ```

### View Control Center

- Set up port forwarding to Control Center web UI from local machine:

  ```cmd
  kubectl port-forward controlcenter-0 9021:9021
  ```

- Browse to Control Center: [http://localhost:9021](http://localhost:9021)

## Create a kafka topic

- Name the new topic: "expedia".

## Prepare the GCS connector configuration

- Create a JSON key for the bucket's service account to give GCS connector access.

## Upload the connector file through the API

## Implement you KStream application

- Add necessary code and configuration to [KStream Application Class](src/main/java/com/epam/bd201/KStreamsApplication.java)

- Build KStream application jar
  ```cmd
  $ mvn package
  ```

- Build [KStream Docker Image](Dockerfile) - insert valid Container Registry here
  ```cmd
  $ docker build -t gcr.io/[your-project-id]/kstream-app:1.0
  ```
  
- Configure your docker for Google Container Registry
  ```cmd
  $ gcloud auth configure-docker 
  ```

- Push KStream image to Container Registry
  ```cmd
  $ docker push gcr.io/[your-project-id]/kstream-app:1.0
  ```

- Generate a JSON key for created service account and add the key as secret to the K8S cluster:
  ```
  $ kubectl create secret docker-registry [key-name] \
    --docker-server=gcr.io \
    --docker-username=_json_key \
    --docker-password="$(cat ./[service-account-key-file.json])" \
    --docker-email=any@valid.email
  ```

- Run you KStream app container in the K8s kluster alongside with Kafka Connect. Don't forger to update [Kubernetes deployment](kstream-app.yaml)
  with valid registry for your image as well as created secret
  ```cmd
  $ kubectl create -f kstream-app.yaml
  ```
