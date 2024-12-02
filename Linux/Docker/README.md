# Linux Docker Setup and Usage Guide

**Execute Commands in the Container** : Use the `docker exec` command to execute commands inside the container. For example, to open a bash shell in the running `ubuntu`, use:
```TERMINAL
docker-compose up -d
```
The `-it` flag again runs the command in interactive mode.

**Running Other Commands** : You can also run specific commands without opening a shell. For example, to update the package list inside the container, you can use:
```TERMINAL
docker exec my_ubuntu_container apt-get update
```

***Shared Folder*** : *Any file or folder that is added in the `Shared` folder will be synced between your computer and the container.*