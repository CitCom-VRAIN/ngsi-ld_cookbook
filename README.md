```bash
git submodule init
git submodule update
```

## Deploy all services:

```bash
make docker
```

![Deploy all services](./docs/imgs/1_docker_up.png)

## Get Jupyter server endpoint:

```bash
make get_jupyter_server
```

![Get Jupyter server](./docs/imgs/2_get_jupyter_endpoint.png)

Copy the Jupyter server endpoint.

```bash
http://127.0.0.1:8888/?token=...
```

## Jupyter notebook configuration:

![1_jupyter_server](./docs/imgs/3-1_notebook_config.png)

![2_jupyter_server](./docs/imgs/3-2_notebook_config.png)

![3_jupyter_server](./docs/imgs/3-3_notebook_config.png)

![4_jupyter_server](./docs/imgs/3-4_notebook_config.png)

## Down all docker services:

![Down all services](./docs/imgs/4_docker_down.png)
