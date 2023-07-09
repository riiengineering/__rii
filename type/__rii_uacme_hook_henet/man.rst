cdist-type__rii_uacme_hook_henet(7)
===================================

NAME
----
cdist-type__rii_uacme_hook_henet - Install the riiengineering uacme hook script
using dns.he.net for domain authentication


DESCRIPTION
-----------
This type installs a `uacme <https://github.com/ndilieto/uacme>`_ hook script
which uses `dns.he.net`_ to authenticate domains.

The hook script is installed on the target as
``/usr/local/share/uacme/hook.henet.sh``.
On OpenWrt the location will be ``/usr/share/uacme/hook.henet.sh``.


REQUIRED PARAMETERS
-------------------
password
   The key configured in dns.he.net to be used to update the DDNS entries.

   NB: this type only supports a single key for all domains.


OPTIONAL PARAMETERS
-------------------
state
   One of:

   present
      the hook script is installed
   absent
      the hook script is not installed


EXAMPLES
--------

.. code-block:: sh

   # Install the script
   __rii_uacme_hook_henet \
      --password 8vQo86xbHRu5dEfu

   # Use the script to acquire a certificate
   require=__rii_uacme_hook_henet/ \
   __uacme_cert "${__target_host:?}" \
      --hook /usr/local/share/uacme/hook.henet.sh


SEE ALSO
--------
* :strong:`uacme`\ (1)
* :strong:`cdist-type__uacme_cert`\ (7)


AUTHORS
-------
* Dennis Camera <dennis.camera--@--riiengineering.ch>


COPYING
-------
Copyright \(C) 2023 Dennis Camera.
You can redistribute it and/or modify it under the terms of the GNU General
Public License as published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.
