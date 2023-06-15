# Lambda Yum Layer Maker

This is a tool to build and push an AWS lambda layer of selected yum packages. The packages will all be contained in one layer if the size is within the 50mb limit for AWS Lambda, otherwise (currently) the script does not push and terminates.

This tool is heavily inspired by the [Yumda](https://github.com/lambci/yumda) repository, which does most of the work (albeit the Dockerfile from there was simply copied to here and edited slightly rather than forking the repo or using the yumda docker image).


# Usage

Simply run the following command:

`docker-compose run --rm make-yum-layer <package1> [<package2> ...]`


# Prerequisites

1) docker must be installed
2) aws-cli must be set up locally and configured so that it can push lambda layers to AWS
3) docker settings (in docker desktop: Settings -> Resources -> File sharing) must be changed to use `~/.aws` as a mount (read-only), which is set in the `docker-compose.yaml`.


# FAQ

### 1) What about if one package already installs another of the given packages as a dependency?

This will be checked for by checking if each package is already installed before trying to install it. The order that the packages are given in the command therefore DOES matter in terms of running time. The end result should be the same, but if a dependency package is installed first before the package which contains that dependency then the script will obviously take longer.

### 2) Why didn't you just extend from the yumbda Dockerfile?

There were several yum packages that I needed to install for the `make-zip.sh` script to work, and these has to be installed at the beginning of the Dockerfile, before the yum configeration was changed to install for Lambda.

### 3) Is there something smarter the tool can do if the layer size is too large, instead of simply terminating?

Yes, I plan on making it create whatever number of lambda layers is needed to keep the size of each one within limits.
It would also be good to create the minimum number of layers possible, but I need to think about this more.

### 4) What about installing yum packages that need importing of another yum repo?

This can be done by adding the repo urls on separate lines in the `add-repos.txt` file.



