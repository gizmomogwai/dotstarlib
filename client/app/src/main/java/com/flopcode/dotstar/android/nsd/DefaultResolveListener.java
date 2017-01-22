package com.flopcode.dotstar.android.nsd;

import android.net.nsd.NsdManager;
import android.net.nsd.NsdServiceInfo;
import android.util.Log;

import static com.flopcode.dotstar.android.Index.LOG_TAG;

public class DefaultResolveListener implements NsdManager.ResolveListener {
  @Override
  public void onResolveFailed(NsdServiceInfo nsdServiceInfo, int i) {
    Log.e(LOG_TAG, "onResolveFailed: " + nsdServiceInfo.getServiceName() + "(" + i + ")");
  }

  @Override
  public void onServiceResolved(NsdServiceInfo nsdServiceInfo) {
    Log.d(LOG_TAG, "onServiceResolved: " + nsdServiceInfo.getServiceName());
  }
}
