/*
 * generated by Xtext 2.14.0
 */
package it.unica.tcs.ide

import com.google.inject.Guice
import it.unica.tcs.BalzacRuntimeModule
import it.unica.tcs.BalzacStandaloneSetup
import org.eclipse.xtext.util.Modules2

/**
 * Initialization support for running Xtext languages as language servers.
 */
class BalzacIdeSetup extends BalzacStandaloneSetup {

	override createInjector() {
		Guice.createInjector(Modules2.mixin(new BalzacRuntimeModule, new BalzacIdeModule))
	}
	
}