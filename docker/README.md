# Listado de contenedores y sus diferentes funcionalidades y usos

[[_TOC_]]

> 📔 Para desplegar algún de estos entornos, desde la raíz del proyecto, ejecutar el siguiente comando: `make docker` y seguir las instrucciones que aparecen.

> ⚠ Los nombres de las carpetas comenzados por `_` no se mostraran para ejecutar.


## orionld_quantumleap-python_dev

Context broker basado en Orion-LD + jupyter notebook para poder desarrollar en python y probar diferentes peticiones y consultas al broker. Además, se incluye el servicio de QuantumLeap para poder almacenar los datos en una base de datos de Time Series (CrateDB).

### Servicios

Esta aplicación se compone de los siguientes servicios:

- develop-env: Jupyter notebook service.
- orionld: Broker.
- mongo-db: Base de datos de la aplicación.
- quantumleap: Servicio de almacenamiento de datos en base de datos de Time Series.
- crate-db: Base de datos de Time Series.

### Virtual memory error (*Fuente: [StackOverflow](https://stackoverflow.com/questions/67528888/1-max-virtual-memory-areas-vm-max-map-count-65530-is-too-low-increase-to-a)*)

Si al ejecutar el servicio de QuantumLeap se obtiene el siguiente error:

> `max virtual memory areas vm.max_map_filling [65530] is too low, increase to at least [262144]`

Modificar el archivo `/etc/sysctl.conf`:

```bash
sudo nano /etc/sysctl.conf
```

Añadir la siguiente línea al final del archivo:

```bash
vm.max_map_count=262144
```

Guardar y salir del archivo. Aplicar los cambios:

```bash
sudo sysctl -p
```
