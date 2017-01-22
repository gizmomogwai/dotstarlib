package com.flopcode.dotstar.android.nsd;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.net.nsd.NsdServiceInfo;

public class DotStarResolveListener extends DefaultResolveListener {
  private final Activity activity;
  private final String serviceName;

  public DotStarResolveListener(Activity activity, String serviceName) {
    this.activity = activity;
    this.serviceName = serviceName;
  }

  @Override
  public void onServiceResolved(NsdServiceInfo nsdServiceInfo) {
    super.onServiceResolved(nsdServiceInfo);

    String host = nsdServiceInfo.getHost().getHostAddress();
    int port = nsdServiceInfo.getPort();
    Uri parsed = Uri.parse("dotstar://" + serviceName + "@" + host + ":" + port);
    activity.startActivity(new Intent(Intent.ACTION_VIEW, parsed));
  }
}
