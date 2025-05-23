.. highlight:: btm

===================
Expressions
===================

This section describes the expression language of |langname|.
Expressions are used, for example, in witnesses, in output values,
within script definitions (with some limitations), and so on.

--------
Literals
--------
|langname| features classical expression literals such as **strings**, **integers** and **booleans**,
and Bitcoin specific ones like **private keys**, **public keys**, **addresses**, **hashes**, **signatures** and **transactions**.

Literals can be expressed directly in the language and
each literal corresponds to a specific type.


Integers
^^^^^^^^
Integers are 64-bit signed numbers, whose type is :balzac:`int`.
Integers syntax is Java-like: digits can be separated with ``_`` to improve readability
and hexadecimal numbers are prefixed with ``0x`` or ``0X``.

.. code-block:: balzac

    eval
        42,
        100_000,
        0Xfff,
        0xff_ff_ff

.. _label_date_delays:

Dates and Delays
""""""""""""""""
|langname| provides two different ways to express integers, in order to improve readability
and avoid errors: **dates** and **delays**.

**Dates** are parsed as integers and represent the amount of seconds that have been passed since :balzac:`1970-01-01T00:00:00`.
|langname| supports three different datetime format from `Java DateTime <https://docs.oracle.com/javase/8/docs/api/java/time/format/DateTimeFormatter.html>`_:

* ``DateTimeFormatter.ISO_LOCAL_DATE`` (e.g. ``2018-01-31``)
* ``DateTimeFormatter.ISO_LOCAL_DATE_TIME`` (e.g. ``2018-01-31T10:30:59``)
* ``DateTimeFormatter.ISO_OFFSET_DATE_TIME`` (e.g. ``2018-01-31T10:30:59+02:00``)

.. code-block:: balzac

    eval
        1969-12-31T23:59:59,  // -1
        1970-01-01T00:00:00,  //  0
        1970-01-01T00:00:01,  //  1
        2018-01-01            //  1514764800

**Delays** can be expressed in minutes, hours, or days. 
The parsing rules are straightforward and conversions are done at parsing time:

* ``INT (m|min|minute|minutes)``: multiply ``INT`` by ``60``
* ``INT (h|hour|hours)``: multiply ``INT`` by ``60 * 60``
* ``INT (d|day|days)``: multiply ``INT`` by ``60 * 60 * 24``

.. code-block:: balzac

    eval
        1m,         // 60
        1min,       // 60
        1minute,    // 60
        2minutes,   // 120
        1h,         // 3600
        1hour,      // 3600
        2hours,     // 7200
        1d,         // 86400
        1day,       // 86400
        2days       // 172800

Strings
^^^^^^^
Strings are sequences of characters, whose type is :balzac:`string`.
Strings are enclosed by ``"`` or ``'``.

.. code-block:: balzac

    eval
        'Hello Balzac!',
        "Hello world!"


Booleans
^^^^^^^^
Booleans consist of two possible values: :balzac:`true` and :balzac:`false`.
Their type is :balzac:`boolean` (or :balzac:`bool` for brevity).


Hashes
^^^^^^
Hashes are sequences of hexadecimal data, whose type is :balzac:`hash`.
Hashes are represented using the prefix :balzac:`hash:` followed by the hash in
hexadecimal format. The number of digits must be even but is otherwise unlimited.

.. code-block:: balzac

    eval
        hash:00,
        hash:73475cb40a568e8da8a045ced110137e159f890ac4da883b6b17dc651b3a8049

See :ref:`Hash Functions <label_hash_functions>` for generating an hash value in |langname|.


Signatures
^^^^^^^^^^
Signatures are sequences of hexadecimal data, whose type is :balzac:`signature`.
Signatures are represented using the prefix :balzac:`sig:` followed by the raw data in
hexadecimal format. The number of digits is not limited but must be even.

.. code-block:: balzac

    eval
        sig:3045022100ca9d6c44745a5b0ee3a1868d55c59bf691826f670dddd8717da828685b...

See :ref:`Cryptographic Functions <label_c_functions>` for generating a signature value in |langname|.


Private keys
^^^^^^^^^^^^
Private keys are represented in the Wallet Import Format (WIF) [#wif]_.
Their type is :balzac:`key` and can be expressed using the prefix :balzac:`key:`
followed by the WIF.

Note that WIF encodes the network identifier, so the same private key has a
different WIF representation in the mainnet and in the testnet.

The sidebar of the `online editor <http://blockchain.unica.it/balzac/>`_
allows to create new random keys (generated server side).

.. code-block:: balzac

    eval
        // testnet
        key:cVj2a2fp4rkykykQR65Bf9FKj7gzjY2QFyn7Kj5BwSmZvn2VQ8To,
        // mainnet (same key)
        key:L5N377fxdo4ibYH92gG4HpkG6tPb55viBwdeDJcgSL7Zg33XmKuL

Public keys
^^^^^^^^^^^
Public keys are sequences of hexadecimal data, whose type is :balzac:`pubkey`.
Public keys are represented using the prefix :balzac:`pubkey:` followed by the raw data in
hexadecimal format. The number of digits is not limited but must be even.

The sidebar of the `online editor <http://blockchain.unica.it/balzac/>`_
allows to create new random keys (generated server side).

.. code-block:: balzac

    eval
        pubkey:027b62af31b2114f960327aa258503a86aad0615618de7a6a1ad9fbb08e5fe7fff


Addresses
^^^^^^^^^
Addresses are represented in the Wallet Import Format (WIF) [#wif]_.
Addresses are obtained from hashing the public key and encoded in WIF.
Their type is :balzac:`address` and can be expressed using the prefix :balzac:`address:`
followed by the WIF.

As for private keys, WIF encodes the network identifier, so the same address has a
different WIF representation in the mainnet and in the testnet.

The sidebar of the `online editor <http://blockchain.unica.it/balzac/>`_
allows to create new random addresses (generated server side).

.. code-block:: balzac
   
    eval
        // testnet
        address:muRL5JJcupSkeXfJun4A4AubnPVZgSmr5q,
        // mainnet (same address)
        address:1EuNnFDe6o1VsRBhCD5nEFhGvPtrmm4dPH


Transactions
^^^^^^^^^^^^
Transactions can be expressed using the prefix :balzac:`tx:` followed by the serialized
transaction data in hexadecimal format. Transactions have type :balzac:`transaction`.

|langname| features new transaction creation, as explained in section :doc:`Transactions <transactions>`.

.. code-block:: balzac

    tx:0200000002a04eb44f83160d5589c6053852fc9e2b88dd27f97422cc869d0c92e9444...

------------------
Boolean operations
------------------
|langname| supports classical boolean operators such as **and**, **or** and **not**.
The syntax is Java-like: ``&&``, ``||`` and ``!`` respectively for and/or/not operations.

The precedence is: unary ``!`` > ``&&`` > ``||``.

The type for a boolean operation is :balzac:`bool` and the type system ensures that
both the operands are of that type.

.. code-block:: balzac

    eval
        a == 5 && (b == "balzac" || b == "Balzac")

---------------------
Arithmetic operations
---------------------
|langname| supports classical arithmetic operators such as **equality**, **addition**, **multiplication** and so on.
The syntax is Java-like: 

- ``a == b``: *true* if ``a`` and ``b`` are equal, *false* otherwise; ``a`` and ``b`` must have the same type
- ``a != b``: *true* if ``a`` and ``b`` are not equal, *false* otherwise; ``a`` and ``b`` must have the same type
- ``a + b``: sum ``a`` and ``b``; both must be :balzac:`int`
- ``a - b``: subtract ``b`` from ``a``; both must be :balzac:`int`
- ``a < b``: *true* if ``a`` is less than ``b``, *false* otherwise (similarly for ``<=``, ``>``, ``>=``); both must be :balzac:`int`
- ``a * b``: multiply ``a`` by ``b``; both must be :balzac:`int`
- ``a / b``: divide ``a`` by ``b`` (truncate); both must be :balzac:`int`
- ``-a``: negate ``a``; it must be :balzac:`int`

The precedence is: unary ``-`` > ``*`` and ``/`` > ``+`` and ``-`` > ``==`` and ``!=`` > ``<``, ``>``, ``<=``, and ``>=``.

.. code-block:: balzac

    eval
        a + 42 / 2,
        a + b > c - 1

--------------------
String Concatenation
--------------------
|langname| supports string concatenation through operator symbol ``+``.
When the left operand is typed as :balzac:`string`,
the right operand is converted to a string and concatenated to the left one.

.. code-block:: balzac

  eval
      "Hello " + "world!",         // "Hello world!"
      "Hello " + "world! " + 42,   // "Hello world! 42"
      "Hello " + 42 + " world!",   // "Hello 42 world!"
      42 + " Hello world!"         // Type error


---
BTC
---
The expression :balzac:`e BTC`, where ``e`` has type :balzac:`int`, multiply ``e`` by ``10^8``.
The return type is :balzac:`int`.

Optionally, ``e`` can be followed by a decimal part ``. INT``, where ``INT`` is a max 8-digit number (not an expression).

.. code-block:: balzac

    eval
        1 BTC,          // 100_000_000
        (1+1) BTC,      // 200_000_000
        (1+1).3 BTC,    // 230_000_000
        (1+1).00003 BTC // 200_003_000

----------
References
----------
References allows to refer to a constant declaration or a transaction declaration
(:doc:`Editor syntax <editor>`),
or a script parameter or a transaction parameter (TODO: link).

The type of a reference depends on the referred object.

A transaction reference has always type :balzac:`transaction`,
while a constant reference has the same type of the declared constant expression.
A parameter reference has the same type of the parameter it refers to.

.. code-block:: balzac

    const zero = 0                // 'zero' has type int
    const one = zero + 1
    const str = zero + "hello"    // type error

    transaction T {...}           // 'T' has type transaction
    const T1 = T                  // also 'T1'

    eval 
        T == T1

Transaction declarations can specify some formal parameters that must be
provided when referencing to the transaction. 
References with actual parameters can be specified as ``refname(exp1,...,expN)``
and the type of the actual parameters must match the formal one.

.. code-block:: balzac

    transaction T(a:int, s:signature) {...}
    const s = sig:...

    eval 
        T(42, s)


.. _label_this:

This
^^^^
The keyword :balzac:`this` can be used to refer the current transaction from
the inside.

See :ref:`Transaction Operations <label_tx_operations>` for concrete use.

-----------
Conditional 
-----------
The conditional statement is expressed as :balzac:`if expIf then expThen else expElse`.
It is an expression: it evaluates ``expThen`` if ``expIf`` evaluates :balzac:`true`,
``expThen`` otherwise.
Note: the *else* branch cannot be omitted.

The type for conditional :balzac:`if expIf then expThen else expElse` is ``a'``,
where :balzac:`bool` is the type for ``expIf`` and ``a'`` is the type of both ``expThen`` and ``expElse``.


.. code-block:: balzac

    eval
        if 1 == 0 then 4 else 6,

        // Error: invalid type string, expected type bool
        if "balzac" then 4 else 6,

        // Error: invalid type string, expected type int
        if 1 == 0 then 4 else "balzac"    


---------------------
Numerical Expressions
---------------------
|langname| features some numerical expressions due to their direct correspondence
in the Bitcoin scripting language.

Max
^^^
The maximum of two numbers can be expresses as :balzac:`max(a,b)`.
This expression has type :balzac:`int` and expects that ``a`` and ``b`` have type :balzac:`int`.

.. code-block:: balzac

    eval
        max(5,10) == 10


Min
^^^
The minimum of two numbers can be expresses as :balzac:`min(a,b)`.
This expression has type :balzac:`int` and expects that ``a`` and ``b`` have type :balzac:`int`.


.. code-block:: balzac

    eval
        min(5,10) == 5

Between
^^^^^^^
The expression :balzac:`between(x,min:max)` checks the number `x` is between ``min`` **inclusive** and ``max`` **exclusive**.
This expression has type :balzac:`bool` and expects that ``x``, ``min`` and ``max`` have type :balzac:`int`.


.. code-block:: balzac

    eval
        between(x,5,10),
        between(x,5,-10)     // invalid range!

Size
^^^^
The :balzac:`size(n)` expression returns the size of `n` in bytes.
This expression has type :balzac:`int` and expects that ``n``  is well typed.

This expression corresponds to ``⌈(log2 |n| / 7)⌉``.

.. _label_hash_functions:

--------------
Hash functions
--------------
|langname| supports the same hashing function of Bitcoin, that are
**sha1**, **sha256**, **ripemd160**, **hash256** and **hash160**.

Sha1
^^^^
The expression :balzac:`sha1(exp)`, where ``exp`` has type 
:balzac:`int`, :balzac:`string`, :balzac:`boolean` or :balzac:`hash`, returns a
SHA-1 digest (type :balzac:`hash`).

.. code-block:: balzac

  eval 
      sha1(42),               // `echo -n -e "\\x2A" | openssl dgst -sha1`
      sha1("hello"),          // `echo -n "hello"    | openssl dgst -sha1`
      sha1(true),             // `echo -n -e "\\x1"  | openssl dgst -sha1`
      sha1(false),            // `echo -n ""         | openssl dgst -sha1`
      sha1(false) == sha1("") // true


Sha256
^^^^^^
The expression :balzac:`sha256(exp)`, where ``exp`` has type 
:balzac:`int`, :balzac:`string`, :balzac:`boolean` or :balzac:`hash`, returns a
SHA-256 digest (type :balzac:`hash`).

.. code-block:: balzac

  eval 
      sha256(42),                 // `echo -n -e "\\x2A" | openssl dgst -sha256`
      sha256("hello"),            // `echo -n "hello"    | openssl dgst -sha256`
      sha256(true),               // `echo -n -e "\\x1"  | openssl dgst -sha256`
      sha256(false),              // `echo -n ""         | openssl dgst -sha256`
      sha256(false) == sha256("") // true


Ripemd160
^^^^^^^^^
The expression :balzac:`ripemd160(exp)`, where ``exp`` has type 
:balzac:`int`, :balzac:`string`, :balzac:`boolean` or :balzac:`hash`, returns a
RIPEMD-160 digest (type :balzac:`hash`).

.. code-block:: balzac

    eval 
        ripemd160(42),                      // `echo -n -e "\\x2A" | openssl dgst -ripemd160`
        ripemd160("hello"),                 // `echo -n "hello"    | openssl dgst -ripemd160`
        ripemd160(true),                    // `echo -n -e "\\x1"  | openssl dgst -ripemd160`
        ripemd160(false),                   // `echo -n ""         | openssl dgst -ripemd160`
        ripemd160(false) == ripemd160("")   // true


Hash256
^^^^^^^
The expression :balzac:`hash256(exp)`, where ``exp`` has type 
:balzac:`int`, :balzac:`string`, :balzac:`boolean` or :balzac:`hash`, applies
the SHA-256 algorithm twice, returning :balzac:`hash`.
It is equivalent to :balzac:`sha256(sha256(exp))`.

.. code-block:: balzac

  eval 
      hash256(42),                  // `echo -n -e "\\x2A" | openssl dgst -sha256 -binary | openssl dgst -sha256`
      hash256("hello"),             // `echo -n "hello"    | openssl dgst -sha256 -binary | openssl dgst -sha256`
      hash256(true),                // `echo -n -e "\\x1"  | openssl dgst -sha256 -binary | openssl dgst -sha256`
      hash256(false),               // `echo -n ""         | openssl dgst -sha256 -binary | openssl dgst -sha256`
      hash256(false) == hash256("") // true


Hash160
^^^^^^^
The expression :balzac:`hash160(exp)`, where ``exp`` has type 
:balzac:`int`, :balzac:`string`, :balzac:`boolean` or :balzac:`hash`, applies
the SHA-256 algorithm followed by RIPEMD-160, returning :balzac:`hash`.
It is equivalent to :balzac:`ripemd160(sha256(exp))`.

.. code-block:: balzac

  eval 
      hash160(42),                  // `echo -n -e "\\x2A" | openssl dgst -sha256 -binary | openssl dgst -ripemd160`
      hash160("hello"),             // `echo -n "hello"    | openssl dgst -sha256 -binary | openssl dgst -ripemd160`
      hash160(true),                // `echo -n -e "\\x1"  | openssl dgst -sha256 -binary | openssl dgst -ripemd160`
      hash160(false),               // `echo -n ""         | openssl dgst -sha256 -binary | openssl dgst -ripemd160`
      hash160(false) == hash256("") // true

--------------
Key Operations
--------------
Key operations allows to convert private keys in public ones, through :balzac:`toPubkey`,
and private/public keys in addresses, through :balzac:`toAddress`.

However, consider that |langname| performs type coercion for keys, if possible:
when a public key is required (e.g. :balzac:`versig` expression),
it is possible to use a private one; when an address is requires,
both a private key and a public one can be used.

toPubkey
^^^^^^^^^

The expression :balzac:`k.toPubkey`, where ``k`` is an expression of type :balzac:`key`, returns the public key of ``k``.
The return type is :balzac:`pubkey`.

.. code-block:: balzac

    const k = key:cVj2a2fp4rkykykQR65Bf9FKj7gzjY2QFyn7Kj5BwSmZvn2VQ8To

    eval
        k.toPubkey

toAddress
^^^^^^^^^

The expression :balzac:`k.toAddress`, where ``k`` is an expression of type :balzac:`key` or :balzac:`pubkey`, returns the public key of ``k``.
The return type is :balzac:`address`.

.. code-block:: balzac

    const k = key:cRmmSTUUQvgJMCmC2dFTkY9R8K7g8uzXnkif6E1qopZvjzrg9oeD
    const kPub = pubkey:02d2da8344ce030e654aad19ec3ef513a80558a780ba89ca4a3f1588346aad2212

    eval
        k.toAddress,
        kPub.toAddress,
        k.toAddress == kPub.toAddress


.. _label_c_functions:

-----------------------
Cryptographic functions
-----------------------

|langname| features cryptographic operations like signing Bitcoin transactions
and verify that a given signature is valid against a public key.


Transaction signature
^^^^^^^^^^^^^^^^^^^^^

The expression :balzac:`sig(k) of T@n`, where ``k`` has type :balzac:`key`, ``T`` has type :balzac:`transaction`,
and ``n`` is an integer (note that it is not an expression of type :balzac:`int`),
generates a new signature.
If omitted, ``n`` is ``0`` and represents the index of the input in which the signature will
be added.
The result type is :balzac:`signature`.



.. code-block:: balzac
    :emphasize-lines: 14,15

    const kA = key:cVj2a2fp4rkykykQR65Bf9FKj7gzjY2QFyn7Kj5BwSmZvn2VQ8To

    transaction TA {
        input = _
        output = 10 BTC : fun(x) . x == 42
    }

    transaction T {
        input = TA@0 : 42
        output = 10 BTC : fun(x) . x == hash:73475cb40a568e8da8a045ced110137e159f890ac4da883b6b17dc651b3a8049
    }

    eval
        sig(kA) of T,    // sig:304402203b082cf8987ab8f29d1ccaf7de77a799f1d45c944d6f6fc1474001420e47c8f102203318ad2677b516166d845843fad4e5801a217fe5bb97b680d6a706d99976d15a01 
        sig(kA) of TA    // ERROR: cannot sign a coinbase transaction

.. Error:: 
    **Cannot sign coinbase or serialized transactions**

    Signatures are commonly used for redeeming an output script,
    **which must be part of the signature** in Bitcoin.
    So, for a generic :balzac:`sig(k) of T@n`, the output script is retrieved from input ``n`` of  ``T``.

    In the previous example, :balzac:`sig(kA) of T` is bound to input ``0`` and
    the output script ``TA@0`` (i.e. :balzac:`fun(x) . x == 42` ) is part of the signature.
    The expression :balzac:`sig(kA) of TA` fails because ``TA`` is a coinbase,
    so there is not connected output script.


Modifiers and input index
"""""""""""""""""""""""""
Bitcoin signatures are more complicated: they support different **transaction modifiers**
and are bound to a **specific index**, that is the index of the input in which the signature will
be added.

The more general form is :balzac:`sig(k)[MODIFIER] of T@INT`, where :balzac:`MODIFIER := AIAO|AISO|AINO|SIAO|SISO|SINO`
and ``INT`` is an integer (note that it is not an expression of type :balzac:`int`).
Modifier and input index can be both omitted. If omitted, the modifier is ``AIAO``, while the index is ``0``.

Each modifier is composed by two parts, ``*I`` and ``*O``, indicating respectively the subset of inputs and of outputs being signed.
The first letter of each part represents all, single, or none. A formal specification can be found in Section 3.3 of [AB+18FC]_.
The following table shows the correspondence of :langname: modifiers and Bitcoin ones:

============================================ ==================================================================
Modifier                         key              Signature Hash Type [BW]_
============================================ ==================================================================
``AIAO``                                        ``SIGHASH_ALL``
``AISO``                                        ``SIGHASH_SINGLE``
``AINO``                                        ``SIGHASH_NONE``
``SIAO``                                        ``SIGHASH_ALL | SIGHASH_ANYONECANPAY``
``SISO``                                        ``SIGHASH_SINGLE | SIGHASH_ANYONECANPAY``
``SINO``                                        ``SIGHASH_NONE | SIGHASH_ANYONECANPAY``
============================================ ==================================================================


Implicit transaction and input index
""""""""""""""""""""""""""""""""""""
Transaction and index can be omitted in one case. Consider the following examples:

.. container:: codecompare

    .. code-block:: balzac

        transaction T {
            input = TA@1 : sig(k) of T
            ...
        }


    .. code-block:: balzac

        transaction T {
            input = TA@1 : s
            ...
        }

        const s = sig(kA) of T@0

Both of the examples below fail due to **cyclic dependency** problems,
since the reference ``T`` creates a cycle.
|langname| overcomes this problem omitting the transaction ``T`` to sign, 
when the expression is used within a transaction, that is:

.. code-block:: balzac

    transaction T {
        input = TA@1 : sig(k)
        ...
    }

In this case, the transaction and the input index are omitted and automatically
refer to the containing transaction ``T`` and input index ``0``.
Differently from :balzac:`sig(k) of T`, the signature :balzac:`sig(kA)` is computed **lazily**,
when evaluating the transaction ``T``.


Signature Verification
^^^^^^^^^^^^^^^^^^^^^^

The expression :balzac:`versig(k1,...,kn; s1,...,sm)`,
where the expressions ``k1`` ... ``kn`` have type :balzac:`pubkey` and ``s1`` ... ``sm`` have type :balzac:`signature` with ``n <= m``,
evaluates :balzac:`true` if the given signatures are valid against the provided keys,
:balzac:`false` otherwise. The result type is :balzac:`bool`.

This expression can appear only within the script of a transaction output. 

.. code-block:: balzac
    :emphasize-lines: 8,12,17

    const kA = key:cVj2a2fp4rkykykQR65Bf9FKj7gzjY2QFyn7Kj5BwSmZvn2VQ8To
    const kApub = kA.toPubkey

    const kB = key:cRmmSTUUQvgJMCmC2dFTkY9R8K7g8uzXnkif6E1qopZvjzrg9oeD

    transaction TA {
        input = _
        output = 10 BTC : fun(x) . versig(kApub; x)
    }

    transaction T {
        input = TA@0 : sig(kA)
        output = 10 BTC : fun(x) . x == 42
    }

    transaction T2 {
        input = TA@0 : sig(kB)          // WARNING: this input does not correctly spends TA@0
        output = 10 BTC : fun(x) . x == 43
    }

Multi-signature verification
""""""""""""""""""""""""""""

The expression :balzac:`versig(k1,...,kn; s1,...,sm)` is called **m-of-n signature verification**,
since all the **m** signatures must be valid against the list of **n** public keys.

Its implementation is the same as Bitcoin: the function tries to verify the last signature with the last key. 
If they match, the verification proceeds to verify the previous signature in the sequence,
otherwise it tries to verify the signature with the previous key
(and the key that failed cannot be used anymore).

Since that a key that failed cannot be used anymore in the verification process
(one shoot), the order of elements in these lists matters.

For example, consider a *2-of-3* signature scheme: 

.. code-block:: balzac
    :emphasize-lines: 10

    const kA = key:cRmmSTUUQvgJMCmC2dFTkY9R8K7g8uzXnkif6E1qopZvjzrg9oeD
    const kB = key:cPoPXKtZJmyVVKMjhphzADUDM3x6aEetk8TFGfctyAtPYPkqufjv
    const kC = key:cVu2WBV1AJsWWG61diDxCrvbuQ9Kk6y7qmoLktCCV5ssht3E3yhx
    const kApub = kA.toPubkey
    const kBpub = kB.toPubkey
    const kCpub = kC.toPubkey

    transaction T {
        input = _
        output = 1BTC: fun(x, y). versig(kApub, kBpub, kCpub; x, y)
    }

The output script  :balzac:`versig(kApub, kBpub, kCpub; x, y)` evaluates true
if  ``x`` and ``y``  respect the keys order.

.. code-block:: balzac

    transaction T1 {
        input = T : sig(kA) sig(kB)         // OK
        output = 1 BTC: fun(x) . x == 42
    }

    transaction T2 {
        input = T : sig(kB) sig(kC)         // OK
        output = 1 BTC: fun(x) . x == 42
    }

    transaction T3 {
        input = T : sig(kB) sig(kA)         // WARNING: this input does not correctly spends T@0
        output = 1 BTC: fun(x) . x == 42
    }

    transaction T4 {
        input = T : sig(kC) sig(kB)         // WARNING: this input does not correctly spends T@0
        output = 1 BTC: fun(x) . x == 42
    }

    transaction T5 {
        input = T : sig(kC) sig(kA)         // WARNING: this input does not correctly spends T@0
        output = 1 BTC: fun(x) . x == 42
    }


----------------
Time constraints
----------------
Time constraints are a special category of expression as: 

* they can be used only within output scripts
* they stop the evaluation if not satisfied (similarly to an exception).

The main purpose of time constraints is to enforce the redeeming
transaction to be valid after a certain time in the future.
In fact, in order to redeem an output script with time constraints,
the redeeming transaction must declare the ``timelock`` field that satisfies them.

Time constraints can express an *absolute time* or a *relative* one.

.. _label_abslock_exp:

Absolute timelocks
^^^^^^^^^^^^^^^^^^
Absolute timelock constraints allow an output script to specify the **absolute time** 
that the redeeming transaction must satisfy.
That time can be either a **block number** or a **timestamp** (in seconds).

CheckBlock
""""""""""
The expression :balzac:`checkBlock blockN : exp`, where ``blockN`` has type :balzac:`int` and
``exp`` has type *T*, evaluates ``exp`` if the redeeming transaction has
a block absolute timelock greater than ``blockN``, fails otherwise. Its type is *T*.

Moreover, the Bitcoin specification imposes that ``blockN < 500_000_000``.

.. code-block:: balzac
    :emphasize-lines: 6,12,18

    const blockN = 500_000

    transaction T {
        input = _
        output = 
            1 BTC: fun(x) . checkBlock blockN : x == 42
    }

    transaction T1 {
        input = T: 42
        output = 0: "test"
        absLock = block blockN + 5
    }

    transaction T2 {
        input = T: 42     // WARNING: time constraint not satisfied
        output = 0: "test"
        absLock = block blockN - 5
    }


CheckDate
"""""""""
The expression :balzac:`checkDate date : exp`, where ``date`` has type :balzac:`int` and
``exp`` has type *T*, evaluates ``exp`` if the redeeming transaction has
a block absolute timelock greater than ``date``, fails otherwise. Its type is *T*.

Moreover, the Bitcoin specification imposes that ``date >= 500_000_000`` (or ``1985-11-05 00:53:20``).

.. code-block:: balzac
    :emphasize-lines: 6,12,18

    const deadline = 2019-01-01

    transaction T {
        input = _
        output = 
            1 BTC: fun(x) . checkDate deadline : x == 42
    }

    transaction T1 {
        input = T: 42
        output = 0: "test"
        absLock = date deadline + 1day
    }

    transaction T2 {
        input = T: 42     // WARNING: time constraint not satisfied
        output = 0: "test"
        absLock = date deadline - 1day
    }


.. _label_rellock_exp:

Relative timelocks
^^^^^^^^^^^^^^^^^^
Relative timelock constraints allow an output script to specify the **delay** 
that the redeeming transaction must satisfy.
That delay can be either a **block number** or a **time delay** (in seconds).

checkBlockDelay
"""""""""""""""
The expression :balzac:`checkBlockDelay blockN : exp`, where ``blockN`` has type :balzac:`int` and
``exp`` has type *T*, evaluates ``exp`` if the redeeming transaction has
a block relative timelock greater than ``blockN``, fails otherwise. Its type is *T*.

Moreover, the Bitcoin specification imposes that ``blockN < 65535``.

.. code-block:: balzac
    :emphasize-lines: 5,11,17

    const blockDelay = 500

    transaction T {
        input = _
        output = 1 BTC: fun(x) . checkBlockDelay blockDelay : x == 42
    }

    transaction T1 {
        input = T: 42
        output = 0: "test"
        relLock = blockDelay + 5 block from T
    }

    transaction T2 {
        input = T: 42     // WARNING: time constraint not satisfied
        output = 0: "test"
        relLock = blockDelay - 5 block from T
    }

checkBlockDelay
"""""""""""""""
The expression :balzac:`checkTimeDelay seconds : exp`, where ``seconds`` has type :balzac:`int` and
``exp`` has type *T*, evaluates ``exp`` if the redeeming transaction has
a time relative timelock greater than ``seconds``, fails otherwise. Its type is *T*.

Moreover, the Bitcoin specification imposes that seconds is a multiple of 512,
and that ``seconds / 512 <= 65535``.

.. code-block:: balzac
    :emphasize-lines: 5,11,17

    const timeDelay = 1day

    transaction T {
        input = _
        output = 1 BTC: fun(x) . checkTimeDelay timeDelay : x == 42
    }

    transaction T1 {
        input = T: 42
        output = 0: "test"
        relLock = timeDelay + 1h from T
    }

    transaction T2 {
        input = T: 42     // WARNING: time constraint not satisfied
        output = 0: "test"
        relLock = timeDelay - 1h from T
    }


.. _label_tx_operations:

----------------------
Transaction operations
----------------------


Input Value
^^^^^^^^^^^
The expression :balzac:`T.input.value`, where ``T`` is an expression
of type :balzac:`transaction`, returns the sum (type :balzac:`int`) of the output values that
``T`` is redeeming.

If a transaction spends more than one output, the user can specify
which input consider as :balzac:`T.input(i,j,...).value`.

.. code-block:: balzac

    transaction coinbase1 {
        input = _    // no input 
        output = 1000: fun(x) . x == 42
    }

    transaction coinbase2 {
        input = _    // no input 
        output = 5000: fun(x) . x == 42
    }

    transaction T {
        input = [
            coinbase1: 42;
            coinbase2: 42
        ]
        output = 1000: fun(x) . x != 0
    }

    eval
        T.input.value,      // 6000
        T.input(0,1).value, // 6000
        T.input(0).value,   // 1000
        T.input(1).value    // 5000

Output Value
^^^^^^^^^^^^
The expression :balzac:`T.output.value`, where ``T`` is an expression
of type :balzac:`transaction`, returns the sum (type :balzac:`int`) of the output values of
``T``.

If a transaction has more than one output, the user can specify
which output consider as :balzac:`T.output(i,j,...).value`.

.. code-block:: balzac

    transaction coinbase {
        input = _    // no input 
        output = 5000: fun(x) . x == 42
    }

    transaction T {
        input = coinbase: 42
        output = [
            3000: fun(x) . x != 0;
            2000: fun(x) . x != 0
        ]
    }

    eval
        T.output.value,       // 5000
        T.output(0,1).value,  // 5000
        T.output(0).value,    // 3000
        T.output(1).value     // 2000


Transaction Fees
^^^^^^^^^^^^^^^^
The expression :balzac:`T.fees`, where ``T`` is an expression
of type :balzac:`transaction`, returns the amount of fees (type :balzac:`int`)
``T``. This is equivalent to :balzac:`T.input.value - T.output.value`.

.. code-block:: balzac

    transaction coinbase {
        input = _    // no input 
        output = 5000: fun(x) . x == 42
    }

    transaction T {
        input = coinbase: 42
        output = [
            3000: fun(x) . x != 0;
            1500: fun(x) . x != 0
        ]
    }

    eval
        T.input.value,        // 5000
        T.output.value,       // 4500
        T.fees                //  500


Transaction ID
^^^^^^^^^^^^^^
The expression :balzac:`T.txid`, where ``T`` is an expression
of type :balzac:`transaction`, returns the transaction id (type :balzac:`hash`)
of ``T``. It corresponds to the double sha256 of the serialized transaction.

.. code-block:: balzac

    transaction coinbase {
        input = _    // no input 
        output = 10 BTC: fun(x) . x == 42
    }

    transaction T {
        input = coinbase: 42
        output = 10 BTC: fun(x) . x != 0
    }

    eval
        T.txid,     // 5adea0f653081857ebe7d422c3e8bcef6d702d54c5ce768a23dd876385f7832a
        T.txid == hash:5adea0f653081857ebe7d422c3e8bcef6d702d54c5ce768a23dd876385f7832a
                    // true



Example: fees and reminders
^^^^^^^^^^^^^^^^^^^^^^^^^^^
The following example shows how the keyword :balzac:`this` can be used inside
a transaction to access its input or output value.

Remember that :ref:`this <label_this>` refers to transaction in which it is used.
The benefit of using :balzac:`this` is that it simplifies handling transaction
fees and reminders. Consider the following example:

.. code-block:: balzac

    //  Alice's public key
    const pubA = pubkey:02249f0fb7e6f0ca9e0f329b24c65c2ad0f792c86856889605ca317aab2a822ffd
    //  Bob's public key
    const pubB = pubkey:0349702eb78f809172dd5501c926d076f60358388ab8f297976d8bd8c7b54909da
    // Miner's fee
    const fee = 0.00013 BTC

    transaction coinbase {
        input = _    // no input 
        output = 10 BTC: fun(x) . x == 42
    }

    transaction T {
        input = coinbase: 42
        output = [
            // pay 1 BTC to Bob
            1 BTC: fun(x) . versig(pubB; x);
            // take the remainder and reward the miner
            this.input.value - 1 BTC - fee: fun(x) . versig(pubB; x);
        ]
    }

Alice owns :balzac:`10 BTC` and she wants to send :balzac:`1 BTC` to Bob.
She creates a transaction ``T`` with two outputs: the first one pays
Bob; the second one gives Alice the remaining bitcoins back,
minus some fee that are left to the miner.

------------
Placeholders
------------
|langname| features a way of expressing a default value for any of its types.
The *underscore* ``_`` can be used in situation in which we are not interested
in providing a value. For example, the signature computation of parametric transaction
which takes a signature as parameter, or an output scripts in which a parameter
is not used.

Consider the following example:

.. code-block:: balzac

    const k = key:cPGZo8VsEopkNFugJpzSaZFhwBVnajhsD5g4XzfcbhDp4VoLdgfw
    const kpub = k.toPubkey

    transaction Coinbase {
        input =  _
        output = 1 BTC : fun(x,n) . versig(kpub;x) && n == 11
    }

    transaction T(s:signature, n:int) {
        input = Coinbase: s n
        output = this.input.value : fun(y, s:int) .
            versig(kpub;y) ||
            checkDate 2019-01-01 : sha256(s) == hash:684888c0ebb17f374298b65ee2807526c066094c701bcc7ebbe1c1095f494fc1
    }

    // compute a signature to redeem Coinbase
    const s = sig(k) of T(_,_)

Transaction ``T`` is parametric: it takes a signature ``s`` and an integer ``n``
and uses them as witnesses to redeem the transaction ``Coinbase``.
In order to compute a valid ``s``, we must instantiate ``T`` with its
actual parameters, otherwise the expression :balzac:`sig(k) of T` complains
with an error. Since ``s`` and ``n`` are witnesses in ``T``,
their value does not affect the computation of the signature,
and it is convenient to use ``_`` to express that we don't care what their value is.
Also, consider that the actual parameter for ``s`` is exactly the value
we want to compute.

The output script of ``T`` takes two parameter ``y`` and ``s`` respectively of
type :balzac:`signature` and :balzac:`int`. The script evaluates true
either providing a valid signature for ``kpub``,
or providing a secret ``s`` after the date :balzac:`2019-01-01`
whose :balzac:`sha256` is equal to
:balzac:`hash:684888c0ebb17f374298b65ee2807526c066094c701bcc7ebbe1c1095f494fc1`.

.. code-block:: balzac

    // redeem T(s) providing a valid signature
    transaction T1 {
        input = T(s,11) : sig(k) _
        output = this.input.value : fun(x) . x == 42
    }

    // redeem T(s) providing the secret
    transaction T2 {
        input = T(s,11) : _ 42
        output = this.input.value : fun(x) . x == 42
        absLock = date 2019-01-01
    }

Transactions ``T1`` and ``T2`` uses ``_`` to express the "unused" actual parameter.


.. rubric:: References

.. [BW] https://bitcoin.org/en/developer-guide#signature-hash-types
.. [#wif] https://bitcoin.org/en/glossary/wallet-import-format
