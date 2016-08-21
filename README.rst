=====
Redis IO
=====

Install Redis by source only

.. note::


    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``redis-io``
---------

Runs the states to install redis, configure the common files, and the users.

``redis-io.sentinel``
----------------

Run the sentinel state to configure and run sentinel service

Pillar customizations:
======================

Overriding the default 6379 node and install 2 nodes instead

.. code-block:: yaml

  redis_io:
    nodes:
      7000:
        bind: '0.0.0.0'
      7001:
        bind: '0.0.0.0'