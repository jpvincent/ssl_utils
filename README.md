# SSL toolbox

## Install

```
$ git clone https://github.com/glejeune/ssl_utils
$ cd ssl_utils
$ ./ssl_utils init >> ".${SHELL}rc
```

## Synopsis

```
ssl_utils v0.0.1

Usage: ssl_utils <command> [args]

Available commands:

chain   : Get domain chain (by Greg)
help    : Help for ssl_utils (by Greg)
info    : Get certificate information (by Greg)
match   : Check is a certificate and a key match (by Greg)
ocsp    : Verify a certificate against an OCSP (by Greg)
pkcs12  : Manipulate PKCS#12 file (by Greg)
plugins : Manage plugins for the ssl_utils CLI (by Greg)
```

## Examples

### Retrieve certificat informations for a domain

```
$ ssl_utils info google.fr

google.fr

subject     : C = US, ST = California, L = Mountain View, O = Google LLC, CN = google.com
serial      : 5DE3D652E79AB4B4
startdate   : Sep 25 07:43:00 2018 GMT
enddate     : Dec 18 07:43:00 2018 GMT
fingerprint : F8:C3:7B:85:DB:89:59:96:EC:E6:08:90:5E:3F:DA:28:DD:C9:12:DE
issuer      : C = US, O = Google Trust Services, CN = Google Internet Authority G3
san         : google.com *.2mdn.net *.android.com [...]
ocsp_uri    : http://ocsp.pki.goog/GTSGIAG3
```

### Retrieve certificat file informations

```
$ ssl_utils info certificate.crt

certificate.crt

type        : certificate
subject     : C = US, ST = California, L = Los Angeles, O = Internet Corporation for Assigned Names and Numbers, OU = Technology, CN = www.example.org
serial      : 0E64C5FBC236ADE14B172AEB41C78CB0
startdate   : Nov  3 00:00:00 2015 GMT
enddate     : Nov 28 12:00:00 2018 GMT
fingerprint : 25:09:FB:22:F7:67:1A:EA:2D:0A:28:AE:80:51:6F:39:0D:E0:CA:21
issuer      : C = US, O = DigiCert Inc, OU = www.digicert.com, CN = DigiCert SHA2 High Assurance Server CA
san         : www.example.com
```

### Retrieve csr file informations

```
$ ssl_utils info example.csr

example.csr

type    : certificate request
subject     : C = US, ST = California, L = Los Angeles, O = Internet Corporation for Assigned Names and Numbers, OU = Technology, CN = www.example.org
```

### Retrieve private key file informations

```
$ ssl_utils info private.key

private.key

type : rsa private key
```

### Check OCSP status

```
$ ssl_utils ocsp google.com

google.com: good
	This Update: Oct 18 19:39:28 2018 GMT
	Next Update: Oct 25 19:39:28 2018 GMT
```

### Display chain

```
$ ssl_utils chain google.com

0: C = US, ST = California, L = Mountain View, O = Google LLC, CN = *.google.com (untrusted)
1: C = US, O = Google Trust Services, CN = Google Internet Authority G3 (untrusted)
2: OU = GlobalSign Root CA - R2, O = GlobalSign, CN = GlobalSign
```

### Check if private key dans certificat match

```
$ ssl_utils match certificat.crt private.key

Certificate : certificat.crt
Key         : private.key

Match!
```

### Create a PKCS12

```
$ ssl_utils pkcs12 create output.p12 --key private.key --cert certificat.crt --passout "s3cr3tp4ss"

Pkcs12: output.p12
```

### Extract private key and/or certificat from PKCS12

```
ssl_utils pkcs12 extract output.p12 --key private.key --cert certificat.crt --passin "s3cr3tp4ss"

Certificat:  certificat.crt
Private key: private.key
```

## Licence

ssl_utils is available for use under the following license, commonly known as the 3-clause (or "modified") BSD license:

Copyright (c) 2019 Grégoire Lejeune<br />

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
* The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.#
