================
Raw Transactions
================

|langname| generates real Bitcoin transactions, both for the mainnet and the testnet.
This page explains how to publish transactions and use real
transactions in |langname|.

---------------------
Publish a transaction
---------------------

|langname| transactions are compiled in a *raw format*,
that is a string of bytes encoded in hexadecimal format,
also referred as *payload* of the transaction.

Users can use the Bitcoin client, or trust online services, to publish
raw transactions.
For example, the explorer BlockCypher allows to publish transaction on the testnet through the page
https://live.blockcypher.com/btc-testnet/pushtx/.

--------------------------
Real transactions as Input
--------------------------

|langname| supports real Bitcoin transactions,
expressed in hexadecimal format.
The prefix :balzac:`tx:`, followed by an hexadecimal string of the transaction
payload, permits to create a constant of type :balzac:`transaction`
that can be used within a transaction input.
Furthermore, |langname| still checks that the witness correctly spends
the input transaction.

.. code-block:: balzac

    const Traw = tx:020000000001028a4415d1954ed05164e294...

    transaction T1 {
        input = Traw : 42
        output = ...
    }


---------------------
Output scripts format
---------------------

|langname| provides an high-level language to express output scripts.
Bitcoin supports several types of output scripts format,
like P2PK (*Pay to Public Key*), which encode the public key in the output,
or P2PKH (*Pay to Public Key Hash*) which encode the hash of the public key in the output
(and the public key must be provided as input),
or P2SH (*Pay to Script Hash*) which encodes the hash of the script in the output and
requires the script to be provided as input (alongside its actual parameters).

|langname| adopts P2SH to encode output scripts.
It follows that, when using a raw transaction as input,
**the output script of the transaction must be provided**
beside the actual parameters.

The script for a P2SH is specified between square brackets
``[]``, after the witnesses.
The following example,
assuming ``Traw`` is a transaction in P2SH format,
specifies the script :balzac:`fun(x) . x == 42`.

.. code-block:: balzac
    :emphasize-lines: 4

    const Traw = tx:020000000001028a4415d1954ed05164e294...

    transaction T1 {
        input = Traw : 42 [fun(x) . x == 42]
        output = ...
    }

If the script is not specified, |langname| complains 
expecting a script. A wrong script will result in a wrong evaluation
of the transaction input, stating that ``T1`` is not correctly
spending ``Traw``.