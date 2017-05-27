/*
 * generated by Xtext 2.11.0
 */
package it.unica.tcs.validation

import com.google.inject.Inject
import it.unica.tcs.bitcoinTM.ActualParameters
import it.unica.tcs.bitcoinTM.BitcoinTMPackage
import it.unica.tcs.bitcoinTM.Declaration
import it.unica.tcs.bitcoinTM.DummyTxBody
import it.unica.tcs.bitcoinTM.Input
import it.unica.tcs.bitcoinTM.KeyBody
import it.unica.tcs.bitcoinTM.KeyDeclaration
import it.unica.tcs.bitcoinTM.Output
import it.unica.tcs.bitcoinTM.Script
import it.unica.tcs.bitcoinTM.SerialTxBody
import it.unica.tcs.bitcoinTM.Signature
import it.unica.tcs.bitcoinTM.UserDefinedTxBody
import it.unica.tcs.bitcoinTM.Versig
import it.unica.tcs.generator.BitcoinTMGenerator
import it.unica.tcs.generator.BitcoinTMGenerator.CompilationException
import it.unica.tcs.validation.BitcoinJUtils.ValidationResult
import org.bitcoinj.core.ScriptException
import org.bitcoinj.core.Transaction
import org.bitcoinj.core.Utils
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.validation.Check

import static org.bitcoinj.script.Script.*

import static extension it.unica.tcs.validation.BitcoinJUtils.*

/**
 * This class contains custom validation rules. 
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class BitcoinTMValidator extends AbstractBitcoinTMValidator {

    @Inject
    private extension BitcoinTMGenerator generator 
    
	/*
	 * INFO
	 */	
	@Check
	def void checkSingleElementArray(UserDefinedTxBody tbody) {
		var inputs = tbody.inputs
		var outputs = tbody.outputs
		
		if (tbody.isMultiIn && inputs.size==1) {
			info("Single element arrays can be replaced by the element itself.",
				BitcoinTMPackage.Literals.USER_DEFINED_TX_BODY__INPUTS
			);	
		}
		
		if (tbody.isIsMultiOut && outputs.size==1) {
			info("Single element arrays can be replaced by the element itself.", 
				BitcoinTMPackage.Literals.USER_DEFINED_TX_BODY__OUTPUTS
			);	
		}
	}

	/*
	 * WARNING
	 */
	@Check
	def void checkIncompleteKey(KeyBody kbody){
		var pvt = kbody.pvt.value
		var pub = kbody.pub.value
		
		if (pvt == "_" && pub == "_") {
			warning("This key cannot be used anywhere.",
				kbody.eContainer,
				BitcoinTMPackage.Literals.KEY_DECLARATION__BODY
			);
		}		
	}
	
	@Check
	def void checkUnusedParameters(Script script){

		for (param : script.params) {
			var references = EcoreUtil.UsageCrossReferencer.find(param, param.eResource());
			
			if (references.size==0)
				warning("Unused variable '"+param.name+"'.", 
					param,
					BitcoinTMPackage.Literals.PARAMETER__NAME
				);			
		}
	}
	
	@Check
	def void checkVerSigDuplicatedKeys(Versig versig) {
		
		for(var i=0; i<versig.pubkeys.size-1; i++) {
			for(var j=i; j<versig.pubkeys.size; j++) {
				
				var k1 = versig.pubkeys.get(i)
				var k2 = versig.pubkeys.get(j)
				
				if (k1==k2) {
					warning("Duplicated public key.", versig, BitcoinTMPackage.Literals.VERSIG__PUBKEYS, i);
					warning("Duplicated public key.", versig,BitcoinTMPackage.Literals.VERSIG__PUBKEYS, j);
				}
			}
		}		
	}
	
	@Check
	def void checkEmptyLambda(Script script) {
		if (script.params.size==0) {
		    
		    if (script.eContainer instanceof Output)
    			warning("This output could be redeemed without providing any arguments.",
    				script.eContainer,
    				BitcoinTMPackage.Literals.OUTPUT__SCRIPT
    			);
    		
    		if (script.eContainer instanceof ActualParameters)
                warning("This output could be redeemed without providing any arguments.",
                    script.eContainer,
                    BitcoinTMPackage.Literals.ACTUAL_PARAMETERS__SCRIPT
                );
		}
	}
	
	/*
     * ERROR
     */
	
    @Check
	def void checkDeclarationNameIsUnique(Declaration t) {
		
		var root = EcoreUtil2.getRootContainer(t);
		for (other: EcoreUtil2.getAllContentsOfType(root, Declaration)){
			
			if (t!=other && t.getName.equals(other.name)) {
				error("Duplicated name '"+other.name+"'.", 
					BitcoinTMPackage.Literals.DECLARATION__NAME
				);
			}
		}
	} 
    	
	
	@Check
	def void checkVerSig(Versig versig) {
		
		if (versig.pubkeys.size>15) {
			error("Cannot verify more than 15 public keys.", 
				BitcoinTMPackage.Literals.VERSIG__PUBKEYS
			);
		}
		
		if (versig.signatures.size > versig.pubkeys.size) {
			error("The number of signatures cannot exceed the number of public keys.", 
				versig,
				BitcoinTMPackage.Literals.VERSIG__SIGNATURES
			);
		}
		
		for(var i=0; i<versig.pubkeys.size; i++) {
			var k = versig.pubkeys.get(i).body
			
			if (k.pvt.value===null && k.pub.value===null) {
				error("The referred public key is not declared and cannot be computed by the private one.", 
					versig,
					BitcoinTMPackage.Literals.VERSIG__PUBKEYS,
					i
				);
			}
		}		
	}
	
	@Check
	def void checkSign(Signature sig) {
		var k = sig.key.body
		
		if (k.pvt.value===null) {
			error("The referred private key is not declared.", 
				sig,
				BitcoinTMPackage.Literals.SIGNATURE__KEY
			);
		}
	}
	
	
		
	@Check
	def void checkKeyDeclaration(KeyDeclaration keyDecl) {
		
		var pvtKey = keyDecl.body.pvt.value;
		var pubKey = keyDecl.body.pub.value;
		
		var pvtErr = false;
		var pubErr = false;
		var ValidationResult validationResult;
		
		/*
		 * WiF format: 	[1 byte version][32 bytes key][1 byte compression (optional)][4 bytes checksum] 
		 * Length:		36 o 38 bytes (without/with compression)
		 */
		if (pvtKey!==null && pvtKey.length!=52) {
			error("Invalid key length.", 
				keyDecl.body.pvt,
				BitcoinTMPackage.Literals.PRIVATE_KEY__VALUE
			)
			pvtErr = true
		}
		
		/*
		 * WiF format: 	[1 byte version][20 bytes key][4 bytes checksum] 
		 * Length:		50 bytes
		 */
		if (pubKey!==null && pubKey.length!=34) {
			error("Invalid key length.", 
				keyDecl.body.pub,
				BitcoinTMPackage.Literals.PUBLIC_KEY__VALUE
			)
			pubErr = true
		}
		
		
		/*
		 * Check if the encoding is valid (like the checksum bytes)
		 */
		if (!pvtErr && pvtKey !== null && !(validationResult=pvtKey.isBase58WithChecksum).ok) {
			error('''Invalid encoding of the private key. The string must represent a valid bitcon address in WiF format. Details: «validationResult.message»''',
				keyDecl.body.pvt,
				BitcoinTMPackage.Literals.PRIVATE_KEY__VALUE
			)
			pvtErr = true
		}		
		
		if (!pubErr && pubKey !== null && !(validationResult=pubKey.isBase58WithChecksum).ok) {
			error('''Invalid encoding of the public key. The string must represent a valid bitcon address in WiF format. Details: «validationResult.message»''',
				keyDecl.body.pub,
				BitcoinTMPackage.Literals.PUBLIC_KEY__VALUE
			)
			pubErr = true
		}
		
				
		/*
		 * Check if the declarations reflect the network declaration
		 */
		if (!pvtErr && pvtKey !== null && !(validationResult=pvtKey.isValidPrivateKey(keyDecl.networkParams)).ok) {
			error('''The address it is not compatible with the network declaration (default is testnet). Details: «validationResult.message»''',
				keyDecl.body.pvt,
				BitcoinTMPackage.Literals.PRIVATE_KEY__VALUE
			)
			pvtErr = true
		}
		
		if (!pubErr && pubKey !== null && !(validationResult=pubKey.isValidPublicKey(keyDecl.networkParams)).ok) {
			error('''The address it is not compatible with the network declaration (default is testnet). Details: «validationResult.message»''',
				keyDecl.body.pub,
				BitcoinTMPackage.Literals.PUBLIC_KEY__VALUE
			)
			pubErr = true
		}
		
		
		/*
		 * Check if the declared keys are a valid pair
		 */
		if (!pvtErr && !pubErr && pubKey!==null && pvtKey!==null && !(validationResult=isValidKeyPair(pvtKey,pubKey,keyDecl.networkParams)).ok
		) {
			error("The given keys are not a valid pair. You can omit the public part (it will be derived).",
				BitcoinTMPackage.Literals.KEY_DECLARATION__BODY
			)
		}
	}
	
	
	@Check
	def void checkUniqueLambdaParameters(Script p) {
		
		for (var i=0; i<p.params.size-1; i++) {
			for (var j=1; j<p.params.size; j++) {
				if (p.params.get(i).name == p.params.get(j).name) {
					error(
						"Duplicate parameter name '"+p.params.get(j).name+"'.", 
						p.params.get(j),
						BitcoinTMPackage.Literals.PARAMETER__NAME, j
					);
				}
			}
		}
	}
	
	@Check
	def void checkSerialTransaction(SerialTxBody tx) {
		
		var ValidationResult validationResult;
        if (!(validationResult=tx.bytes.isValidTransaction(tx.networkParams)).ok) {
			error(
				'''The string does not represent a valid transaction. Details: «validationResult.message»''',
				BitcoinTMPackage.Literals.SERIAL_TX_BODY__BYTES
			);
		}
	}
	
	@Check
	def void checkUserDefinedTx(UserDefinedTxBody tbody) {
		
		/*
		 * Verify that inputs are valid
		 */
		var hasError = false;
		
		for (input: tbody.inputs) {
		    var valid = input.checkInputIndex && input.checkInputExpressions
		    hasError = hasError || !valid
		}
		
		if(hasError) return;  // interrupt the check
		
		/*
		 * pairwise verify that inputs are unique
		 */
		for (var i=0; i<tbody.inputs.size-1; i++) {
			for (var j=i+1; j<tbody.inputs.size; j++) {
				
				var inputA = tbody.inputs.get(i)
				var inputB = tbody.inputs.get(j)
				
				// these checks need to be executed in this order
				var areValid = checkInputsAreUnique(inputA, inputB)
				
				hasError = hasError || !areValid
			}
		}
		
		if(hasError) return;  // interrupt the check

		/*
		 * Verify that the fees are positive
		 */
        hasError = !tbody.checkFee
        
        if(hasError) return;  // interrupt the check
        
        /*
         * Verify that the input correctly spends the output
         */
        hasError = tbody.correctlySpendsOutput
	}
	
	def boolean checkInputIndex(Input input) {

        var outIndex = input.txRef.idx
        var int numOfOutputs
        
        if (input.txRef.tx.body instanceof UserDefinedTxBody) {
            var inputTx = input.txRef.tx.body as UserDefinedTxBody
            numOfOutputs = inputTx.outputs.size
        }
        else if (input.txRef.tx.body instanceof SerialTxBody) {
            var inputTx = input.txRef.tx.body as SerialTxBody
            numOfOutputs = inputTx.toTransaction.outputs.size
        }
        else if (input.txRef.tx.body instanceof DummyTxBody){
            numOfOutputs = 1
        }
        else throw new IllegalStateException
        
        if (outIndex>=numOfOutputs) {
            error("This input is pointing to an undefined output script.",
                input.txRef,
                BitcoinTMPackage.Literals.TRANSACTION_REFERENCE__IDX
            );
            return false
        }
        
        return true
    }

    def boolean checkInputExpressions(Input input) {
        
        var outputIdx = input.txRef.idx

        if (input.txRef.tx.body instanceof UserDefinedTxBody) {
            var inputTx = input.txRef.tx.body as UserDefinedTxBody
            var outputScript = inputTx.outputs.get(outputIdx).script;
            
            var numOfExps = input.actual.exps.size
            var numOfParams = outputScript.params.size
            
            if (numOfExps!=numOfParams) {
                error(
                    "The number of expressions does not match the number of parameters.",
                    input,
                    BitcoinTMPackage.Literals.INPUT__ACTUAL
                );
                return false
            }
            return true
        }
        else if (input.txRef.tx.body instanceof SerialTxBody) {
            
            var refTx = input.txRef.tx.body.toTransaction
            
            if (refTx.getOutput(outputIdx).scriptPubKey.payToScriptHash &&
                input.actual.script===null
            ) {
                error(
                    "You must specify the redeem script when referring to a P2SH output of a serialized transaction.",
                    input,
                    BitcoinTMPackage.Literals.INPUT__ACTUAL
                );
                return false
            }
        }
        
        return true
    }
    
    def boolean checkInputsAreUnique(Input inputA, Input inputB) {
        if (inputA.txRef.tx==inputB.txRef.tx && 
            inputA.txRef.idx==inputB.txRef.idx
        ) {
            error(
                "You cannot redeem the output twice.",
                inputA,
                BitcoinTMPackage.Literals.INPUT__TX_REF
            );
        
            error(
                "You cannot redeem the output twice.",
                inputB,
                BitcoinTMPackage.Literals.INPUT__TX_REF
            );
            return false
        }
        return true
    }
	
    def boolean checkFee(UserDefinedTxBody tx) {
        
        var amount = 0L
        
        for (in : tx.inputs) {
            if (in.txRef.tx.body instanceof UserDefinedTxBody) {
                var index = in.txRef.idx
                var output = (in.txRef.tx.body as UserDefinedTxBody).outputs.get(index) 
                var value = output.value.value
                if (output.value.unit=="BTC") value*=Math.pow(value, 8) as int
                amount+=value                
            }
            else if (in.txRef.tx.body instanceof SerialTxBody){
                var index = in.txRef.idx
                var txbody = (in.txRef.tx.body as SerialTxBody).bytes
                var value = txbody.getOutputAmount(tx.networkParams, index)
                amount+=value
            }
            else {
                // dummy tx body
                return true
            }
        }
        
        for (out : tx.outputs) {
            var value = out.value.value
            if (out.value.unit=="BTC") value*=Math.pow(value, 8) as int
                amount-=value
        }

        if (amount==0) {
            warning("Fees are zero.",
                tx.eContainer,
                BitcoinTMPackage.Literals.TRANSACTION_DECLARATION__BODY
            );
        }
        
        if (amount<0) {
            error("The transaction spends more than expected.",
                tx.eContainer,
                BitcoinTMPackage.Literals.TRANSACTION_DECLARATION__BODY
            );
            return false;
        }
        
        return true;
    }
    
    def boolean correctlySpendsOutput(UserDefinedTxBody tbody) {
        
        for (var i=0; i<tbody.inputs.size; i++) {

            var input = tbody.inputs.get(i)
            var org.bitcoinj.script.Script inScript
            var org.bitcoinj.script.Script outScript            
            
            try {
                var Transaction tx = tbody.toTransaction

                inScript = tx.getInput(i).scriptSig
                outScript = tx.getInput(i).outpoint.connectedOutput.scriptPubKey
                inScript.correctlySpends(
                    tx, 
                    i, 
                    outScript, 
                    ALL_VERIFY_FLAGS
                )
                
//                println("input "+inScript+" correctly redeem output "+tx.getOutput(outIndex).scriptPubKey)
                
            } catch(ScriptException e) {

                warning(
                    '''
                    This input does not redeem the specified output script. 
                    
                    Details: «e.message»
                    INPUT:   «inScript»
                    OUTPUT:  «outScript»
                    «IF outScript.isPayToScriptHash»
                    REDEEM SCRIPT:  «new org.bitcoinj.script.Script(inScript.chunks.get(inScript.chunks.size-1).data)»
                    REDEEM SCRIPT HASH:  «Utils.HEX.encode(Utils.sha256hash160(new org.bitcoinj.script.Script(inScript.chunks.get(inScript.chunks.size-1).data).program))»
					«ENDIF»''',
                    input.eContainer,
                    BitcoinTMPackage.Literals.USER_DEFINED_TX_BODY__INPUTS, 
                    i
                );
            } catch(CompilationException e) {
                
            }
        }
        return true
    }
    
}