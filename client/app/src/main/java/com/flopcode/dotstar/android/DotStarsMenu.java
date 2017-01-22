package com.flopcode.dotstar.android;

import android.app.Activity;
import android.net.nsd.NsdManager;
import android.net.nsd.NsdServiceInfo;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.SubMenu;
import com.flopcode.dotstar.android.nsd.DefaultDiscoveryListener;
import com.flopcode.dotstar.android.nsd.Discovery;
import com.flopcode.dotstar.android.nsd.DotStarResolveListener;
import com.flopcode.dotstar.android.nsd.Resolve;

import java.util.concurrent.Callable;
import java.util.concurrent.FutureTask;

import static com.flopcode.dotstar.android.Index.LOG_TAG;

public class DotStarsMenu {
  public final SubMenu menu;
  public NsdManager nsdManager;
  private DotStarDiscoveryListener discoveryListener;
  private Discovery discovery;

  public DotStarsMenu(Activity activity, Menu parent, NsdManager nsdManager) {
    menu = parent.addSubMenu("DotStar Installations");
    this.nsdManager = nsdManager;
    discoveryListener = new DotStarDiscoveryListener(activity, this);
    discover();
  }

  private void discover() {
    if (discovery == null) {
      discovery = new Discovery(nsdManager, discoveryListener, "_dotstar._tcp");
    }
    discovery.start();
  }

  public void destroy() {
    discovery.destroy();
  }

  public class DotStarDiscoveryListener extends DefaultDiscoveryListener {
    private final Activity activity;
    private DotStarsMenu dotstars;
    private NsdManager.ResolveListener resolveListener;
    private Resolve resolve;

    public DotStarDiscoveryListener(Activity activity, DotStarsMenu dotstars) {
      this.activity = activity;
      this.dotstars = dotstars;
    }

    void onDestroy() {
      resolve.onDestroy();
    }

    @Override
    public void onServiceFound(final NsdServiceInfo nsdServiceInfo) {
      super.onServiceFound(nsdServiceInfo);
      final String serviceName = nsdServiceInfo.getServiceName();

      if (!menuContains(serviceName)) {
        Log.d(LOG_TAG, "adding " + serviceName + " to menu");
        activity.runOnUiThread(new Runnable() {
          @Override
          public void run() {
            MenuItem serviceItem = dotstars.menu.add(serviceName);
            serviceItem.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
              @Override
              public boolean onMenuItemClick(MenuItem menuItem) {
                Log.e(LOG_TAG, "onMenuITemClick: " + menuItem);
                dotstars.discovery.destroy();
                resolveListener = new DotStarResolveListener(activity, serviceName);
                resolve = new Resolve(dotstars.nsdManager, resolveListener, nsdServiceInfo);
                return true;
              }
            });
          }
        });
      }
    }

    private boolean menuContains(final String serviceName) {
      FutureTask<Boolean> contains = new FutureTask<>(new Callable<Boolean>() {
        @Override
        public Boolean call() throws Exception {
          Menu m = dotstars.menu;
          for (int i = 0; i < m.size(); ++i) {
            MenuItem item = m.getItem(i);
            Log.d(LOG_TAG, "title: " + item.getTitle());
            Log.d(LOG_TAG, "condensed: " + item.getTitleCondensed());
            if (serviceName.equals(item.getTitle())) {
              return true;
            }
          }
          return false;
        }
      });
      activity.runOnUiThread(contains);
      try {
        return contains.get();
      } catch (Exception e) {
        Log.e(LOG_TAG, "...", e);
        return false;
      }
    }

    private void removeFromMenu(final String serviceName) {
      activity.runOnUiThread(new Runnable() {
        @Override
        public void run() {
          Menu m = dotstars.menu;
          for (int i = 0; i < m.size(); ++i) {
            MenuItem item = menu.getItem(i);
            Log.d(LOG_TAG, "title: " + item.getTitle());
            Log.d(LOG_TAG, "condensed: " + item.getTitleCondensed());
            if (serviceName.equals(item.getTitle())) {
              m.removeItem(i);
              break;
            }
          }
        }
      });
    }

    @Override
    public void onServiceLost(NsdServiceInfo nsdServiceInfo) {
      super.onServiceLost(nsdServiceInfo);

      final String serviceName = nsdServiceInfo.getServiceName();
      removeFromMenu(serviceName);
    }

  }

}
