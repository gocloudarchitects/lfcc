# Cloud Basics: Docker

## Installing Docker

1. Install Docker and enable rootless mode in a Linux VM

2. Install Docker on your system, whether it be Windows, Mac, or Linux.

3. Bookmark [Awsome-docker](https://awesome-docker.netlify.app/#useful-resources), a curated list of Docker resource and projects.  This is a great resource to see how docker is implemented to build projects, and become informed of useful tools.  In particular:
   - [Where to start](https://awesome-docker.netlify.app/#where-to-start)
   - [Where to start (Windows)](https://awesome-docker.netlify.app/#where-to-start-windows)
   - [Open Container Initiative Image Spec](https://github.com/opencontainers/image-spec/blob/main/annotations.md) - this is the community definition for docker images
   - [Valuable Docker Links](http://nane.kratzke.pages.mylab.th-luebeck.de/about/blog/2014/08/24/valuable-docker-links/) - A huge list of instructional articles about Docker

## Running and Modifying Containers

1. Deploy a [local docker registry](https://docs.docker.com/registry/deploying/)
   - You can run as root or rootless, so run it in the environment you use primarily
   - Run it on port `5005`
   - Name the container `registry`
   - Ensure it runs when you reboot your system
   - Ensure you can push to and pull from this registry

2. Docker containers are ideal for running simple services or web applications locally to your machine. To familiarize yourself with setting up docker containers, consider these projects, or any other you may find interesting.
   - [Portainer](https://community.portainer.io/?hsLang=en) - Web-based docker container and image manager
   - [DokuWiki](https://www.dokuwiki.org/dokuwiki) - Databaseless Wiki. Can be used for personal documentation.
   - [Pi-hole](https://pi-hole.net/) - This is a very common project. It's a DNS-based whole-network ad-blocker (warning: a mistake with your DNS can bring your network down)

   **NOTE:** Make sure you know what each step does and what each command is for.

## Customizing Container Images

1. Read [Common Dockerfile Mistakes](https://blog.developer.atlassian.com/common-dockerfile-mistakes/)

2. Take the latest python container, and create a build for container image with the following criteria
   - Use pip to install ansible and jmespath
   - If you run the container with no arguments, it will run `ansible-playbook -i inventory.yml -e @vars.yml site.yml`
   - If you run the container with arguments, it will run `ansible-playbook` with the supplied arguments
   - Set the variable `ANSIBLE_HOST_KEY_CHECKING=False`
   - Name the container `ansible-playbook` with version tag `v0.1`
   - Push the container to your local registry set up in the previous exercise

## Deploying Apps with Docker Compose

1. Read [How to scale Docker Containers with Docker-Compose](https://brianchristner.io/how-to-scale-a-docker-container-with-docker-compose/) - This article introduces the concept of loadbalancing and scaling, which we will see in Kubernetes, and provides another example of a Docker Compose project. Follow the exercise.

2. Stop and remove your docker registry.  Launch a secure docker registry, referring to the [docker registry documentation](https://docs.docker.com/registry/deploying/)
   - Use the [steps to generate a self-signed certificate from the Arch Linux Wiki](https://wiki.archlinux.org/title/OpenSSL#Generate_a_self-signed_certificate_with_private_key_in_a_single_command). **HINT:** add the `-nodes` to avoid encrypting the key, which will not work.
   - Run as root or rootless, depending on which you are using primarily
   - Put docker mounts in `/opt/registry`
     - Set directory permissions using the `docker` group and setguid bit
   - Push your ansible container to the local registry
   - Try pulling other containers and pushing them to this registry

**HINT:** If you're having trouble, try looking at the container logs.  On my system, this was `docker logs registry_registry_1`


# ANSWERS

## Running and Modifying Containers - Exercise 1

The command I ran on my system to accomplish this was:

```bash
docker run -d --restart-always -p 5005:5000 --name registry registry:2
```

To push containers to the registry, you need to tag the images.

```bash
docker tag registry:2 localhost:5005/registry:newtag
docker push localhost:5005/registry:newtag
```

The name and tag are arbitrary, but you have to tag with the hostname and port of the push destination.


## Customizing Container Images

Answers may vary, but this is one solution:

```bash
$ cat Dockerfile
FROM python:3.9
MAINTAINER Nathan Curry
COPY requirements.txt /ansible
WORKDIR /ansible
RUN pip install -r requirements.txt
ENTRYPOINT ["ansible-playbook"]
CMD ["-i","inventory.yml","-e","@vars.yml","site.yml"]
$ cat requirements.txt 
ansible
jmespath
```

- I could simply pass the packages to pip, but a `requirements.txt` is easier to maintain
- ENTRYPOINT is the command that is run, and it will not be replaced by arguments passed to the container at runtime
  - You can override ENTRYPOINT by explicitly passing `--entrypoint`
- CMD is a list of arguments. You can place the command here, but it will be replaced if you include any arguments

To build, tag, and push:

```bash
docker build . -t ansible
docker tag . ansible localhost:5000/ansible:v0.1
docker push localhost:5000/ansible:v0.1
```

You can also tag at build time, ie `docker build . -t localhost:5000/ansible:v0.1`

## Deploying Apps with Docker Compose

1. Create directories

   ```bash
   sudo mkdir /opt/registry/{data,auth,certs} -p
   sudo chown nc:docker -R /opt/registry    # user owner is my primary user, group is docker
   sudo chmod 4750 -R /opt/registry
   ```

   **HINT:** you can add your user to the docker group with `usermod`

2. Create and place key and cert

   ```bash
   cd /opt/registry/certs
   openssl req -x509 -newkey rsa:4096 -days 180 -keyout key.pem -out cert.pem -nodes
   # Selected all default options, but put "Docker Registry" in "Common Name"
   ```

3. Create and place password file

   ```bash
   docker run --entrypoint htpasswd httpd:2 --help   # Checked options
   docker run --entrypoint htpasswd httpd:2 -Bbn nc secretpassword > /opt/registry/auth/htpasswd
   ```

4. Edit docker-compose.yml file

   ```yaml
   $ cat /opt/registry/docker-compose.yml
   registry:
     restart: always
     image: registry:2
     ports:
       - 5000:5000
     environment:
       REGISTRY_HTTP_TLS_CERTIFICATE: /certs/cert.pem
       REGISTRY_HTTP_TLS_KEY: /certs/key.pem
       REGISTRY_AUTH: htpasswd
       REGISTRY_AUTH_HTPASSWD_PATH: /auth/htpasswd
       REGISTRY_AUTH_HTPASSWD_REALM: Registry Realm
     volumes:
       - /opt/registry/data:/var/lib/registry
       - /opt/registry/certs:/certs
       - /opt/registry/auth:/auth
   ```

5. Run registry in daemonized mode, login, push container

   ```bash
   docker-compose --project-directory /opt/registry up -d
   docker login
   # enter credentials when prompted
   docker push localhost:5000/ansible:v0.1
   ```