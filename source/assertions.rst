==========
Assertions
==========

|langname| supports *assertions*. The statement :balzac:`assert exp`,
where ``exp`` is an expression of type :balzac:`boolean`,
checks that the given expression evaluates to true.
If the expression evaluates to false, it throws an error.

.. code-block:: balzac

    const a = 42

    assert a == 42  // ok
    assert a != 0   // ok
    assert a == 1   // Assertion error


For example, we can check that the derived address and pubkey from ``k`` are equal to some
literals.

.. code-block:: balzac

    const k = key:cSyt51FL53tLuG9TGSLxtTapDWquwT6XN6NSbqh6PdquYXCmscXN

    assert k.toAddress == address:moytPifb6CmkaPZZ5c85HN553fwsgVro8M
    assert k.toPubkey == pubkey:02a599b9400ff0ac9f2eb37c444162d5296e78acefc8e7d216581c16916668396b


A variant of the assert statement allows specifying an error message.
The syntax is :balzac:`assert exp : msg`, where ``msg`` has type :balzac:`string`.

The following example checks that the ID of the transaction ``T`` corresponds to
a given literal hash. This is useful when we publish a transaction on the blockchain
and we want to be sure that our transaction (modeled in Balzac) corresponds to the real one.

.. code-block:: balzac

    const kA = key:cSFqKAaCUGHZoGDrcreo3saZpMv9NvcVmRZVbVddbodEuzWNCDNt
    const kB = key:cSyt51FL53tLuG9TGSLxtTapDWquwT6XN6NSbqh6PdquYXCmscXN

    transaction T_deposit {
        input = _
        output = 1BTC: fun(x). versig(kA; x)
    }

    assert T.txid == hash:df2ad5bdc765e7c0be1a6964f67c71d9be11e635cfeadc6920ff0973433dc464 
           : "Found: " + T.txid

    transaction T {
            input = T_deposit: sig(kA) 
            output = this.input.value : fun(x). versig(kB; x)
    }

