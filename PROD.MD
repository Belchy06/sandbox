## Running the Tinkerbell stack on an Ubuntu 20.04 host
Run `ip a` to obtain a list of network interfaces available to the machine. Testing so far has only been done through the host's ethernet adapter.

Make note of the ethernet adapter, for the rest of this guide it will be `enp5s0`.

Run `./prerun.sh enp5s0 > pre.env`
This script generates a few environment variables that are referenced from the `setup.sh` script, namely:
- TINKERBELL_HOST_IP
- TINKERBELL_CIDR
- SUBNET_MASK

The values for these variables are extracted from the interface specified. You must specify the IP address of your network's default gateway with the following command:
`export GATEWAY_IP={YOUR_GATEWAY_IP}`

### Default workflows
If you wish to have default workflows enabled within the Tinkerbell stack, run `export ENABLE_DEFAULT_WORKFLOWS=1`.

For default workflows to work, ensure you have disabled the DHCP functionality of your router disabled. With default workflows enabled, Boots becomes a fully fledged DHCP server with IP assignment functionality. In order to assign these IPs, Boots needs some more environment variables to be set:
- START_IP
- LEASE_RANGE

The START_IP represents the first IP that can be assigned to worker machines. This is an IPv4 CIDR, ensuring the subnet mask matches that of the host. eg If the host IP is 192.168.1.254/24, the START_IP *could* be 192.168.1.100/24

The LEASE_RANGE represents the number of IPs that Boots can assign (eg 50), starting from the START_IP. Ensure the LEASE_RANGE does not contain the host IP.
Note: I enabled a static IP for the host at \*\*\*.\*\*\*.\*\*\*.254. This gives me the largest range of possible IPs to assign


### Generating environment variables
With the specified environment variables set, we can now generate the remainder of them. First run:
`source pre.env` 
To load the first set of environment variables, and then run
`./generate-env.sh enp5s0 > .env`

Then load all of the generated environment variables with:
`source .env`

### Generating the images that accompany the default workflow example
Run `./create-images.sh`
This script builds the actions in ./deploy/workflow-images, downloads the remaining images from Tinkerbell's quay.io action hub and then pushes all of the required images to the local Tinkberbell image registry.

### Starting the stack
Change directory to ./deploy and run `docker-compose up -d`.

Tinkerbell is now ready to receive templates and workflows. Check out all the Tinkerbell services are running.

`docker-compose ps`


The response shows the running services. 

At this point, you may wish to open a second terminal to show the logs from the services during the rest of the setup phase. Open another in the sandbox directory
`source .env && cd deploy && docker-compose logs -f tink-server nginx boots`

The Tinkerbell server, and more importantly the CLI, are now managed like a standard Docker Compose project. To make the rest of the setup process easier I like to create an alias for the Tink CLI, just to cut down on the amount of type that needs to be done. This alias can be created with:
`alias tink="docker exec -i deploy_tink-cli_1 tink"`

### Uploading the default template
The default template contains 4 actions, each of which are imperative to the provisioning and installation of an OS on bare metal.

#### **disk-wipe**
The disk-wipe action wipes all of the disks connected to the bare metal

#### **image2disk**
The image2disk action streams a raw OS image and writes it to a specified block storage disk. 
The raw image can be optionally compressed. In the case the image is compressed, set the parameter COMPRESSED to true.

#### **writefile**
The writefile action writes the value in the CONTENT field to a file, saved on the specified disk and file path

If using the Tinkerbell provisioning engine with ThanOS, the contents of the file contain a json object the specifies the X resolution (resx), Y resolution (resy) and url the Firefox navigates to on start (url).

Example:
~~~~
{
  "resx":1920,
  "resy":1440,
  "url": "google.com"
}
~~~~

#### **reboot**
The reboot action only works with the OSIE alternate, Hook.  
The reboot action touches a file that the hook-docker system service watches for. Once the file is detected, it creates a syscall to reboot the machine.

To upload the default template, open a terminal in the `deploy` folder and run: `tink template create ./default.yml`

### You are now all set, enjoy Tinking