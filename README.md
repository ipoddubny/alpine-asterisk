# Small Docker image for Asterisk on Alpine Linux

| **WARNING**. New versions of Asterisk redefine memory management functions (malloc, free), which is incompatible with MUSL libc used by Alpine. |
| -------- |

## Goals
 - Create a minimal Docker image for Asterisk
 - Build it from source to make it easy to build any versions, including rcs, betas or git master
 - Use the bundled pjproject, not the one from the repositories
   - It's the officially recommended way to install pjsip
   - 2.5.5 currently available in Alpine repositories has multiple critical
     security vulnerabilities (AST-2017-009, AST-2017-003, AST-2017-002)
   - The bundled version is maintained by the Asterisk development team,
     as of today it's 2.7.1 for Asterisk 13 and 15,
     with some patches backported from the upstream.

## Limitations
 - No support for databases except for sqlite, no odbc modules
 - Some rarely used channel drivers and other features are not built:
   - channel drivers: MGCP, Skinny, Unistim
   - DUNDi
   - some other applications and modules

## Example usage
```
docker run -it --rm \
  --network=host \
  --name=asterisk \
  --mount type=bind,source=/etc/asterisk,destination=/etc/asterisk,ro=true \
  --mount type=bind,source=/var/lib/asterisk/sounds,destination=/var/lib/asterisk/sounds,ro=true \
  --mount type=bind,source=/var/lib/asterisk/moh,destination=/var/lib/asterisk/moh,ro=true \
  --mount type=bind,source=/var/log/asterisk,destination=/var/log/asterisk \
  ipoddubny/alpine-asterisk \
  /usr/sbin/asterisk -cvvvvf
```

## References
 - Alpine Asterisk package source: https://git.alpinelinux.org/cgit/aports/tree/main/asterisk
 - Asterisk in an Alpine Linux LXC container: https://paulgorman.org/technical/asterisk-alpine-lxc.txt
