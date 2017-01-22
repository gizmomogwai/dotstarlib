package com.flopcode.dotstar.android.nsd;

import android.net.nsd.NsdManager;

public class Discovery {
  final NsdManager manager;
  final NsdManager.DiscoveryListener listener;
  private final String serviceType;
  private boolean started = false;

  public Discovery(NsdManager manager, NsdManager.DiscoveryListener listener, String serviceType) {
    this.manager = manager;
    this.listener = listener;
    this.serviceType = serviceType;
    start();
  }

  public synchronized void destroy() {
    if (started) {
      started = false;
      this.manager.stopServiceDiscovery(listener);
    }
  }

  public synchronized void start() {
    if (!started) {
      this.manager.discoverServices(serviceType, NsdManager.PROTOCOL_DNS_SD, this.listener);
      started = true;
    }
  }
}
