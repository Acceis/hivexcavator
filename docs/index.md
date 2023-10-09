# HivExcavator

[![GitHub forks](https://img.shields.io/github/forks/acceis/hivexcavator)](https://github.com/acceis/hivexcavator/network)
[![GitHub stars](https://img.shields.io/github/stars/acceis/hivexcavator)](https://github.com/acceis/hivexcavator/stargazers)
[![GitHub license](https://img.shields.io/github/license/acceis/hivexcavator)](https://github.com/acceis/hivexcavator/blob/master/LICENSE.txt)
[![Rawsec's CyberSecurity Inventory](https://inventory.raw.pm/img/badges/Rawsec-inventoried-FF5050_flat.svg)](https://inventory.raw.pm/tools.html#hivexcavator)

![GitHub commit activity](https://img.shields.io/github/commit-activity/y/acceis/hivexcavator)

![](https://acceis.github.io/hivexcavator/logo-hivexcavator.png)

> Extracting the contents of Microsoft Windows Registry (hive) and display it as a colorful tree but mainly focused on parsing BCD files to extract WIM files path for PXE attacks.

## What is it?

![](https://acceis.github.io/hivexcavator/SeqDiag.svg)

_Microsoft Deployment Toolkit_ (MDT) (integrated in _System Center Configuration Manager_ (SCCM)) helps to automate the deployment of Windows and to manage OS images.

Some devices load and install the OS directly over a network connection via _Preboot Execution Environment_ (PXE) images managed and hosted by MDT. Devices will ask a PXE configuration over _Dynamic Host Configuration Protocol_ (DHCP) then a _Trivial File Transfer Protocol_ (TFTP) connection is used to retrieve the PXE boot image.

Attackers are mainly interested in PXE boot images for:

- Modifying the image: injecting an _Elevation of Privilege_ (EoP) vector or backdoor the image to gain administrative access or spy on the compromised host with a _Man-in-the-Middle_ (MitM) attack.
- Read the image: parsing the image for passwords and secrets.

For the second scenario, the retrieved PXE configuration will give us a list of _Boot Configuration Data_ (BCD) files used by Microsoft's Windows Boot Manager.

Those BCD files are like databases and are using the same format as Windows Registry hives. Parsing the BCD files allows retrieving the path of _Windows Imaging Format_ (WIM) files that are the bootable images (PXE boot images). Indeed, the BCD files retrieved via PXE will only contain the pointers towards WIM files and other stuff like _System Deployment Image_ (SID) files.

Note: TFTP doesn't allow to list available files so one has to know the exact path to retrieve them, that's why parsing the BCD file is required.

After downloading the WIM files, the attack can parse them to retrieve, for example, credentials.

The PowerShell library [PowerPXE](https://github.com/wavestone-cdt/powerpxe) does all that **BUT** while most functions (like `Get-FindCredentials`) work on PowerShell Core ([open-source variant of PowerShell](https://github.com/PowerShell/PowerShell) that runs on Linux and macOS), some functions like `Get-WimFile` only work on Windows PowerShell (the closed source variant of PowerShell that runs only on Windows).

Note: `Get-WimFile`, used to extract WIM file path, uses _Common Information Model_ (CIM) PowerShell module that is available exclusively on Windows.

So while PowerPXE can be used to find and extract credentials from PXE server or detect BCD files on PXE server on Linux and macOS with PowerShell Core, it can't export WIM path from BCD files on those OSes at it can only on Windows.

A Linux and macOS based attacker, certainly don't want to create a Windows _Virtual Machine_ (VM) only to parse a file, that is why HivExcavator is there: to allow you **parsing BCD files on Linux and macOS to extract WIM files path**.

## Prerequisites

Install [Hivex](https://github.com/libguestfs/hivex) (part of [libguestfs](https://libguestfs.org/)) because, unfortunately, the library and [Ruby wrapper](https://github.com/libguestfs/hivex/tree/master/ruby) have not been made available as a gem.

Find the name of the package for your distro on [Repology](https://repology.org/project/hivex/versions).

## Installation

Quick installation:

1. Satisfy the prerequisites
2. Install the gem

```plaintext
$ gem install hivexcavator
```

[![Packaging status](https://repology.org/badge/vertical-allrepos/hivexcavator.svg)](https://repology.org/project/hivexcavator/versions)
[![Gem Version](https://badge.fury.io/rb/hivexcavator-hash.svg)](https://badge.fury.io/rb/hivexcavator-hash)
![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/acceis/hivexcavator)

## Example

Example: `hivexcavator ~/test/pxe/conf.bcd`

![](https://acceis.github.io/hivexcavator/hive-tree.png)

## Documentation

- [Homepage](https://acceis.github.io/hivexcavator)
- [CHANGELOG](https://acceis.github.io/hivexcavator/CHANGELOG)
- [About](https://acceis.github.io/hivexcavator/about)

## Author

Made by Alexandre ZANNI ([@noraj](https://pwn.by/noraj/)) at [ACCEIS](https://www.acceis.fr/).
