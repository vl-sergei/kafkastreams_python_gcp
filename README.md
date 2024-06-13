
## Kafka connect in Kubernetes

### Create a custom docker image

For running the GCS connector, the Docker image was created and builded. Reference was included into CP config yaml file.

![alt text](pics/docker_connect.PNG)

### Data was uploaded to GCP Cloud Storage into the bucket created in prior via Terraform

![alt text](pics/bucket.PNG)

### GCP Kuberentes engine cluster was created via Terraform and connected to kubectl service

![alt text](pics/k8s.PNG)

![alt text](pics/cluster_conn.PNG)

## Launch Confluent for Kubernetes

### Create a namespace

- Create the namespace to use:

  ```bash
  kubectl create namespace confluent
  ```

- Set this namespace to default for your Kubernetes context:

  ```bash
  kubectl config set-context --current --namespace confluent
  ```

### Install Confluent for Kubernetes

- Add the Confluent for Kubernetes Helm repository:

  ```bash
  helm repo add confluentinc https://packages.confluent.io/helm
  helm repo update
  ```

- Install Confluent for Kubernetes:

  ```bash
  helm upgrade --install confluent-operator confluentinc/confluent-for-kubernetes
  ```

### Install Confluent Platform

- Install all Confluent Platform components:

  ```bash
  kubectl apply -f ./confluent-platform.yaml
  ```

- Install a sample producer app and topic:

  ```bash
  kubectl apply -f ./producer-app-data.yaml
  ```

### View Control Center

- Set up port forwarding to Control Center web UI from local machine:

  ```bash
  kubectl port-forward controlcenter-0 9021:9021
  ```

- Browse to Control Center: [http://localhost:9021](http://localhost:9021)

![alt text](pics/forwarding.PNG)

## Create a kafka topics

- Name the new topics: "expedia" and "expedia_ext"

![alt text](pics/both_topics.PNG)

## Preparing and uploading the GCS connector configuration file through the API

- Config file was uploaded and connector was estableshed:

![alt text](pics/connector.PNG)

- As a result the data from GCP Cloud Storage was uploaded through "expedia" topic and proceeded:

![alt text](pics/overview.PNG)
![alt text](pics/topic_msgs.PNG)

## Creating and deploying image with Kafka Streams job

### Creating of app docker image

- To execute Python app, the Docker image was created and builded:

![alt text](pics/docker_app.PNG)

### Deploing of app docker image

```bash
kubectl create -f kstream-app.yaml 
```

 - Check that everything is deployed:

  ```bash
  kubectl get pods -o wide 
  ```

![alt text](pics/get_pods.PNG)
![alt text](pics/workloads.PNG)

## Executing the Kafka stream job, procceding and enriching the data

After deploing the app starts to consume data from "expedia" topic, proceede it and write into "expedia_ext" topic:

![alt text](pics/eapedia_ext.PNG)

### Creating Kafka stream, table and visualization the enriched data

Creating a stream:

![alt text](pics/create_stream.PNG)

Creating a table:

![alt text](pics/create_table.PNG)

Data visualization was created from ksql cli:

```bash
kubectl exec -it ksqldb-0  -- ksql 
```

![alt text](pics/final_tab.PNG)
