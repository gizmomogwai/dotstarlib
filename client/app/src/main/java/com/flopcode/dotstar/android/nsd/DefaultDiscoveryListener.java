package com.flopcode.dotstar.android.nsd;

import android.net.nsd.NsdManager;
import android.net.nsd.NsdServiceInfo;
import android.util.Log;
import com.flopcode.dotstar.android.Index;

public class DefaultDiscoveryListener implements NsdManager.DiscoveryListener {

  @Override
  public void onStartDiscoveryFailed(String s, int i) {
    Log.e(Index.LOG_TAG, "onStartDiscoveryFailed: " + s + "(" + i + ")");
  }

  @Override
  public void onStopDiscoveryFailed(String s, int i) {
    Log.e(Index.LOG_TAG, "onStopDiscoveryFailed: " + s + "(" + i + ")");
  }

  @Override
  public void onDiscoveryStarted(String s) {
    Log.d(Index.LOG_TAG, "onDiscoveryStarted: " + s);
  }

  @Override
  public void onDiscoveryStopped(String s) {
    Log.d(Index.LOG_TAG, "onDiscoveryStopped: " + s);
  }

  @Override
  public void onServiceFound(NsdServiceInfo nsdServiceInfo) {
    Log.d(Index.LOG_TAG, "onServiceFound " + nsdServiceInfo.getServiceName());
  }

  @Override
  public void onServiceLost(NsdServiceInfo nsdServiceInfo) {
    Log.d(Index.LOG_TAG, "onServiceLost " + nsdServiceInfo.getServiceName());
  }
}
