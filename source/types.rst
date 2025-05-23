=====
Types
=====

|langname| is a statically typed language, i.e. the type of each variable is determined at compile time.

The table below shows the list of types 


.. table:: List of types and examples
   :widths: 20 40 30

   ===================== ================================================================== ==================================================================
   Type                  Description                                                        Example
   ===================== ================================================================== ==================================================================
   :balzac:`int`         64-bit signed number                                               :balzac:`42`
   :balzac:`string`      A string of characters                                             :balzac:`"foo"`

                                                                                            :balzac:`'bar'`
   :balzac:`boolean`     Either true or false value                                         :balzac:`true` :balzac:`false`
   :balzac:`hash`        A string of bytes in hexadecimal representation                    :balzac:`hash:c51b66bced5e4491001bd702669770dccf440982`
   :balzac:`key`         A Bitcoin private key in the Wallet Input Format [#f1]_            :balzac:`key:KzKP2XkH93yuXTLFPMYE89WvviHSmgKF3CjYKfpkZn6qij1pWuMW`
   :balzac:`address`     A Bitcoin address in the Base58 format [#f2]_                      :balzac:`address:1GT4D2wfwu7gJguvEdZXAKcENyPxinQqpz`

   :balzac:`pubkey`      A raw public key as hexadecimal string                             :balzac:`pubkey:032b6cb7aa033a063dd01e20a971d6d4f85eb27ad0793b...`
   :balzac:`signature`   A raw signature as hexadecimal string                              :balzac:`sig:30450221008319289238e5ddb1aefa26db06a5f40b8a212d1...`
   :balzac:`transaction` A Bitcoin transaction, as hex payload or txid                      :balzac:`tx:0100000001cab433976b8a3dfeeb82fe6a10a59381d2f91341...`

                                                                                            :balzac:`txid:0d7748674c8395cf288500b1c64330605fec54ae0dfdb22a...`
   ===================== ================================================================== ==================================================================

.. Hint:: 
   **Type Coercion**

   Type coercion is an automatic type conversion by the compiler.
   In other words, some types can be *safely converted* to other ones:

   - :balzac:`key` can be used within expressions/statements where a type :balzac:`pubkey` or :balzac:`address` is expected;
   - :balzac:`pubkey` can be used where a type :balzac:`address` is expected.

.. Hint:: 
   **Type Inference**

   Types can be declared explicitly (left box) 
   or omitted (right box) if the type checker can statically infer them.


   .. container:: codecompare

      .. code-block:: balzac
         
         const n:int = 42

      .. code-block:: balzac
         
         const n = 42

.. rubric:: References

.. [#f1] https://en.bitcoin.it/wiki/Wallet_import_format
.. [#f2] https://en.bitcoin.it/wiki/Invoice_address (only P2PKH and P2SH are currently supported)
