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
i.e. transactions are serialized to a string of bytes encoded in hexadecimal format.

You can use the Bitcoin client, or trust online services, to publish
raw transactions.
For example, the explorer BlockCypher allows to publish transaction on the testnet through the page
https://live.blockcypher.com/btc-testnet/pushtx/.
Since private keys are never part of a transaction, it's perfectly fine to
use external services to broadcast a transaction.
At worst, the transaction may be dropped.

.. figure:: _static/img/push-tx.png
    :scale: 75 %
    :class: img-border
    :align: center


--------------------------
Real transactions as Input
--------------------------

|langname| supports real Bitcoin transactions,
expressed in hexadecimal format.
The prefix :balzac:`tx:`, followed by the hexadecimal string of a serialized transaction,
permits to create a constant of type :balzac:`transaction`
that can be used as input.

.. code-block:: balzac

    const Traw = tx:020000000001028a4415d1954ed05164e294...

    transaction T1 {
        input = Traw : sig(k)
        output = ...
    }
    
You can obtain the serialized format of a transaction with id ``tx_id``,
calling the API ``https://chain.so/api/v2/tx/BTC/tx_id``.
The serialized transaction is in the field ``"tx_hex"``.
For a testnet transaction, the API to call is ``https://chain.so/api/v2/tx/BTCTEST/tx_id``.

|langname| still checks that the witness correctly spends
the input transaction.
However, there is a limitation that depends on Bitcoin output 
scripts format and
the following section explains 
how |langname| compiles the output scripts and how to use
the two kinds of transaction that it may generate.

---------------------
Output scripts format
---------------------

|langname| provides an high-level language to express output scripts.
Bitcoin supports some types of output scripts format. Some of them are:

- **P2PK** (*Pay to Public Key*), which encode the public key in the output.
  This format is **deprecated** by P2PKH.

- **P2PKH** (*Pay to Public Key Hash*) which encode the hash of the public key in the output,
  and the public key must be provided as input (alongside a signature).

- **P2SH** (*Pay to Script Hash*) which encodes the hash of the script in the output and
  requires the script to be provided as input (alongside its actual parameters).

|langname| adopts P2PKH and P2SH to encode output scripts.

^^^^^
P2PKH
^^^^^

|langname| compiles :balzac:`fun(x) . versig(k;x)` as P2PKH,
i.e. Pay to Public Key Hash.

The public key is hashed and stored in the output script.
Anyone who wants to redeem this output must provide a valid signature
and the public key that corresponds with this hash.

This pattern is so common and widespread that the notion of
*Bitcoin address* arose from it.
In Bitcoin, an address is the **hash** of the public key encoded in
`Base 58 <https://en.wikipedia.org/wiki/Base58>`_ 
(plus other information like the network type and a checksum).
See `Address - Bitcoin Wiki <https://en.bitcoin.it/wiki/Address>`_
for further details.

As an example, consider the transaction ``T`` defined below.

.. code-block:: balzac

    const kpub = pubkey:020ffce813c6e42b76e56aaa794a001f9f27e09d9dbe5a5a83d9712f9ba4fdbe8b

    transaction T {
        input = _
        output = 10 BTC : fun(x) . versig(kpub;x)
    }

The public key ``kpub`` is hashed and stored in the output script of ``T``.
The Bitcoin address associated to ``kpub`` is ``mkYSk8yaNfurMmo5aPsPPDym6hjz6VM2un``
and can be obtained in Balzac typing :balzac:`kpub.toAddress`.

A transaction ``T1`` that spends ``T`` is shown in the following example.

.. code-block:: balzac

    const k = key:cRLAzgrJJQA61pcUkUeasn2FDXLEuWxfXMY4YeGs3cXUCf7vj4bU

    transaction T1 {
        input = T : sig(k)
        output = 10 BTC : fun(x) . ... 
    }

The witness of ``T1`` provides a valid signature for ``kpub``.
However, remember that ``kpub`` is not stored in the output script of ``T``,
but only its hash.
In theory, the public key should be provided alongside with the signature :balzac:`sig(k)`,
so that it can be compared with the hash in the output script before the validation.
In practice, |langname| recognizes P2PKH output scripts and provides
the public key for us.

.. code-block:: balzac
    :emphasize-lines: 4

    const k = key:cRLAzgrJJQA61pcUkUeasn2FDXLEuWxfXMY4YeGs3cXUCf7vj4bU

    transaction T1 {
        input = T : sig(k) kpub     // Error: invalid number of witnesses
        output = 10 BTC : fun(x) . ... 
    }

"""""""""""""""""""""""""""""
Serialized P2PKH transactions
"""""""""""""""""""""""""""""

Transactions that encode P2PKH outputs can be smoothly used in |langname|.

.. code-block:: balzac

    const kpub = pubkey:020ffce813c6e42b76e56aaa794a001f9f27e09d9dbe5a5a83d9712f9ba4fdbe8b

    transaction T {
        input = _
        output = 10 BTC : fun(x) . versig(kpub;x)
    }
    
    const Traw = tx:02000000010000000000000000000000000000000000000000000000000000000000000000ffffffff02012affffffff0100ca9a3b0000000017a91413e090734f942aba5c7cdaf98caaa7ce19cadc368700000000

    eval T == Traw  // true


In this example, the transaction ``Traw`` is obtained by the serialization of ``T``.
As you can notice below, ``T1`` spends ``Traw`` and
there is no difference between redeeming ``T`` or ``Traw``.

.. code-block:: balzac
    :emphasize-lines: 4

    const k = key:cRLAzgrJJQA61pcUkUeasn2FDXLEuWxfXMY4YeGs3cXUCf7vj4bU

    transaction T1 {
        input = Traw : sig(k)
        output = 10 BTC : fun(x) . ... 
    }


^^^^
P2SH
^^^^

|langname| compiles all the output scripts that are different from
:balzac:`fun(x) . versig(k;x)` as P2SH,
i.e. Pay to Script Hash.

The script is serialized, then hashed, and finally stored in the output script.
Anyone who wants to redeem this output must provide
the actual parameters for the script
and the script itself, serialized. If the script hash matches the
hash in the output script and its execution evaluates to true,
the output is redeemed.

Consider the following example.

.. code-block:: balzac

    const kpub = pubkey:020ffce813c6e42b76e56aaa794a001f9f27e09d9dbe5a5a83d9712f9ba4fdbe8b

    transaction T {
        input = _
        output = 10 BTC : fun(x, secret:string) . 
            versig(kpub;x) && sha1(secret) == hash:aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d
    }

The output script takes two inputs, a signature ``x`` and a string ``secret``,
and evaluates to true if ``x`` is valid signature for ``kpub``
and the :balzac:`sha1` of ``secret`` is equal to the embedded hash.

A transaction ``T1`` that spends ``T`` is shown in the following example

.. code-block:: balzac

    const k = key:cRLAzgrJJQA61pcUkUeasn2FDXLEuWxfXMY4YeGs3cXUCf7vj4bU

    transaction T1 {
        input = T : sig(k) "hello"
        output = 10 BTC : fun(x) . ... 
    }

Remember that the output script of ``T`` is not stored when the transaction
is serialized. So, alongside the actual parameters :balzac:`sig(k) "hello"`,
the transaction ``T1`` should provide the output script.
However, in |langname| this is not required because it is done automatically.


""""""""""""""""""""""""""""
Serialized P2SH transactions
""""""""""""""""""""""""""""

Problems arise when the output script of a *serialized* transaction is a P2SH.
In fact, a serialized P2SH only contains the hash of the script.

Consider the following example.

.. code-block:: balzac

    const kpub = pubkey:020ffce813c6e42b76e56aaa794a001f9f27e09d9dbe5a5a83d9712f9ba4fdbe8b

    transaction T {
        input = _
        output = 10 BTC : fun(x, secret:string) . 
            versig(kpub;x) && sha1(secret) == hash:aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d
    }

    const Traw = tx:02000000010000000000000000000000000000000000000000000000000000000000000000ffffffff02012affffffff0100ca9a3b0000000017a9149a43eb9f4ae32ff9234dc1ba92ebfeffc83c18e78700000000

    eval T == Traw      // true


In this example, the transaction ``Traw`` is obtained by the serialization of ``T``.
However, the following example will not work.

.. code-block:: balzac
    :emphasize-lines: 4

    const k = key:cRLAzgrJJQA61pcUkUeasn2FDXLEuWxfXMY4YeGs3cXUCf7vj4bU

    transaction T1 {
        input = Traw : sig(k) "hello"   // Error
        output = 10 BTC : fun(x) . ... 
    }


When using a raw transaction as input,
**the output script of the transaction must be provided**
beside the actual parameters. 
There is no chance that |langname| will guess what is the output script
just looking at its hash.

The script, called *redeem script*,
is specified between square brackets
``[]``, after the witnesses.
In the following example, ``T1`` spends ``Traw``
providing the redeem script.

.. code-block:: balzac
    :emphasize-lines: 4

    const k = key:cRLAzgrJJQA61pcUkUeasn2FDXLEuWxfXMY4YeGs3cXUCf7vj4bU

    transaction T1 {
        input = Traw : sig(k) "hello" [fun(x, secret:string) . versig(kpub;x) && sha1(secret) == hash:aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d]
        output = 10 BTC : fun(x) . ...
    }


If the script is not specified, |langname| complains 
that the redeem script is missing.
Also, a wrong script will result in a wrong evaluation,
and ``T1`` does not redeem ``Traw``.
