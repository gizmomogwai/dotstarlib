package com.flopcode.dotstar.android.nsd;

import android.net.nsd.NsdManager;
import android.net.nsd.NsdServiceInfo;

public class Resolve {
  final NsdManager manager;
  final NsdManager.ResolveListener listener;
  private final NsdServiceInfo nsdServiceInfo;

  public Resolve(NsdManager manager, NsdManager.ResolveListener listener, NsdServiceInfo nsdServiceInfo) {
    this.manager = manager;
    this.listener = listener;
    this.nsdServiceInfo = nsdServiceInfo;
    resolve();
  }

  public void resolve() {
    this.manager.resolveService(nsdServiceInfo, listener);
  }

  public void onDestroy() {
  }
}
