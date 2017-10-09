/*
 * Copyright 2017 Nicola Atzei
 */

package it.unica.tcs.lib.model;

import static com.google.common.base.Preconditions.checkState;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.function.Supplier;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class Participant implements Runnable {
	
	private static final Logger logger = LoggerFactory.getLogger(Participant.class);
	
	private final String name;
	private final ExecutorService executor;
	private final ServerSocketDaemon receiverDeamon;
	
	public Participant(String name) {
		this(name, 0);
	}
	
	public Participant(String name, int port) {
		this.name = name;
		this.executor = Executors.newCachedThreadPool();
		this.receiverDeamon = new ServerSocketDaemon(port);
		this.executor.execute(receiverDeamon);
		try {
			this.receiverDeamon.waitUntilOnline();
		} catch (InterruptedException e) {
			throw new IllegalStateException("Cannot start the server");
		}
		logger.trace("Listening on port "+this.getPort());
	}
	
	public String getName() {
		return this.name;
	}
	
	public InetAddress getHost() throws UnknownHostException {
		return InetAddress.getLocalHost();
	}
	
	public int getPort() {
		return receiverDeamon.getPort();
	}

	abstract public void run();
	
	public void parallel(Process... processes) {
		for (Process process : processes)
			executor.execute(process);
	}

	public static ChoiceElement choiceElm(Prefix prefix) {
		return new ChoiceElement(prefix);
	}
	
	public static ChoiceElement choiceElm(Prefix prefix, Process next) {
		return new ChoiceElement(prefix, next);
	}
	
	private static Process choice(Prefix... prefixes) {
		return choice(Arrays.stream(prefixes).map(ChoiceElement::new).toArray(ChoiceElement[]::new));
	}
	
	public static Process choice(ChoiceElement... prefixes) {
		checkState(prefixes.length>0);
		return new Choice(prefixes);
	}
	
	public static Process ask(String... txsid) {
		return choice(PrefixFactory.ask(txsid));
	}
	
	public static Process ask(List<String> txsid) {
		return choice(PrefixFactory.ask(txsid));
	}
	
	public static Process check(Supplier<Boolean> condition) {
		return choice(PrefixFactory.check(condition));
	}
	
	public static Process check() {
		return choice(PrefixFactory.check());
	}
	
	public static Process put(String txhex) {
		return choice(PrefixFactory.put(txhex));
	}
			
	public static void send(Integer msg, Participant p) {
		send(msg.toString(), p);
	}
	
	public static void send(String msg, Participant p) {
		
		try (
			Socket socket = new Socket(p.getHost(), p.getPort());
			BufferedReader reader = new BufferedReader(new InputStreamReader(socket.getInputStream()));
			PrintWriter writer = new PrintWriter(socket.getOutputStream());
		) {
			socket.setKeepAlive(true);
			logger.trace("connected to "+socket.getInetAddress()+":"+socket.getPort()+", local port"+socket.getLocalPort());
			logger.trace("isConnected "+socket.isConnected());
			logger.trace("keepalive "+socket.getKeepAlive());
			logger.trace("isBound "+socket.isBound());
			logger.trace("isClosed "+socket.isClosed());
			logger.trace("toString "+socket.toString());
			logger.trace("sending "+msg);
			writer.println(msg.trim());
			writer.flush();
			logger.trace("waiting the server to close the connection");
			reader.readLine();
		} catch (UnknownHostException e) {
			e.printStackTrace();
			throw new RuntimeException(e);
		} catch (IOException e) {
			e.printStackTrace();
			throw new RuntimeException(e);
		} 
	}
	
	public String receive(Participant p) {
		logger.trace("reading");
		try {
			return receiverDeamon.read();
		} catch (InterruptedException e) {
			throw new RuntimeException(e);
		}
	}
	
	public void stop() throws InterruptedException {
		logger.trace("shutting down the executor service");
		this.executor.shutdownNow();
		this.executor.awaitTermination(30, TimeUnit.DAYS);
	}
	
}
