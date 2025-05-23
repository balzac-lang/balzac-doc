============
Transactions
============

.. highlight:: btm

|langname| provides a simple syntax to express Bitcoin transactions,
which is summarized as follows:

.. code-block:: balzac

    transaction txName {
        input = ...
        output = ...
        absLock = ...   // optional
        relLock = ...   // optional
    }

------
Inputs
------

The :balzac:`input` field of a transaction specifies 

* the **transaction output**, that is a transaction and an output index;
* the **witnesses**, that are the actual parameters with which the output script is evaluated.

The syntax to express the pair transaction output/witnesses is :balzac:`T@n : e1 e2 e3`,
where ``T`` is an expression of type :balzac:`transaction`,
``n`` is an integer (not an expression),
and ``e1 e2 e3`` are the witnesses expressions whose type must match the type
of the parameters of the transaction output script.

.. code-block:: balzac

    transaction A { 
        ...
        output = 1 BTC : fun(n:int) . n == 42
    }

    transaction B {
        input = A@0 : 42
        ...
    }

Generally, the :balzac:`input` field can contain a list of ``T@n : wit``, denoted by the list delimiters ``[...]`` and separated by ``;``. Moreover, ``@n`` can be omitted and the output index is assumed to be 0.
For example:

.. code-block:: balzac

    transaction B {
        input = [
            A : 42;         // same of A@0 : 42
            A1@3 : sig(k)
        ]
        ...
    }

See :doc:`expressions` for details.


-------
Outputs
-------
The :balzac:`output` field of a transaction specifies 

* the **bitcoin amount**, that is the value of the output;
* the **script**, that is the condition that the redeeming transaction must satisfy.

The syntax to express the pair bitcoin amount/script is :balzac:`B : fun(x:TypeX,...,y:TypeY) . E`,
where ``B`` is an expression of type :balzac:`int`,
``x`` and ``y`` are script parameters,
``TypeX`` and ``TypeY`` are types (e.g. :balzac:`int`, :balzac:`string`, ...)
and ``E`` is an expression of type :balzac:`boolean`.

.. code-block:: balzac

    transaction A { 
        ...
        output = 1 BTC : fun(n:int) . n == 42
    }

Generally, the :balzac:`output` field can contain a list of :balzac:`B : fun(x:TypeX,...,y:TypeY) . E`,
denoted by the list delimiters ``[...]`` and separated by ``;``.
For example:

.. code-block:: balzac

    transaction A {
        ...
        output = [
            1 BTC : fun(x:int) . x == 42;
            0.5 BTC : fun(y:signature) . versig(k; y)
        ]
        ...
    }

See :doc:`expressions` for details.

-------
AbsLock
-------
The field :balzac:`absLock` allows to specify when a transaction will be valid.

The time can be expressed in two ways:

*   | :balzac:`absLock = block N`
    | where ``N`` is an expression of type :balzac:`int` representing the **block number** at which the transaction will be valid
    

*   | :balzac:`absLock = date D`
    | where ``D`` is an expression of type :balzac:`int` representing the **date** (in seconds from :balzac:`1970-01-01`) at which the transaction will be valid.

The expressions ``N`` and ``D`` are subject to the same constraints of :ref:`label_abslock_exp`.

Refer to :ref:`Dates and Delays <label_date_delays>` for convenient ways for expressing dates.

-------
RelLock
-------
The field :balzac:`relLock` allows to specify when a transaction will be valid.

The time can be expressed in two ways:

*   | :balzac:`relLock = N block from T`
    | where ``N`` and ``T`` are expressions of type :balzac:`int` and :balzac:`transaction` respectively, representing the **number of blocks from T** at which the transaction will be valid
    

*   | :balzac:`relLock = D from T`
    | where ``D`` and ``T`` are expressions of type :balzac:`int` and :balzac:`transaction` respectively, representing the **seconds from T** at which the transaction will be valid

The expressions ``N`` and ``D`` are subject to the same constraints of :ref:`label_rellock_exp`,
while the expression ``T`` must evaluate to one of the input transactions.

Refer to :ref:`Dates and Delays <label_date_delays>` for convenient ways for expressing delays.
