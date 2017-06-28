package com.flopcode.dotstar.android;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences.Editor;
import android.net.Uri;
import android.net.nsd.NsdManager;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.design.widget.CoordinatorLayout;
import android.support.design.widget.NavigationView;
import android.support.design.widget.Snackbar;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.*;
import android.view.View.OnClickListener;
import android.widget.TextView;
import butterknife.BindView;
import com.flopcode.dotstar.android.DotStarApi.DotStar;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

import java.util.ArrayList;
import java.util.List;

import static butterknife.ButterKnife.bind;

/**
 * An activity representing activity list of Presets. This activity
 * has different presentations for handset and tablet-size devices. On
 * handsets, the activity presents activity list of items, which when touched,
 * lead to activity {@link PresetDetailActivity} representing
 * item details. On tablets, the activity presents the list of items and
 * item details side-by-side using two vertical panes.
 */
public class Index extends AppCompatActivity {

  public static final String LOG_TAG = "DotStar";
  public static final String DOT_STAR_SERVER = "dotStarServer";
  @BindView(R.id.preset_list)
  public RecyclerView list;
  @BindView(R.id.coordinator)
  public CoordinatorLayout coordinator;
  /**
   * Whether or not the activity is in two-pane mode, i.e. running on activity tablet
   * device.
   */
  private boolean mTwoPane;
  private SimpleItemRecyclerViewAdapter adapter;
  private DotStarsMenu dotstars;

  public static String getConnectionPrefs(Context c) {
    return PreferenceManager.getDefaultSharedPreferences(c).getString(DOT_STAR_SERVER, "");
  }

  public static void storeConnectionPrefs(Context c, String host, int port) {
    Editor e = PreferenceManager.getDefaultSharedPreferences(c).edit();
    String connection = "http://" + host + ":" + port;
    Log.d(LOG_TAG, "switching to: " + connection);
    e.putString(DOT_STAR_SERVER, connection);
    e.commit();
  }

  public static DotStar getDotStar(String connection) {
    try {
      return DotStarApi.createDotStar(connection);
    } catch (Exception e) {
      return null;
    }
  }


  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    handleIntents(getIntent());

    setContentView(R.layout.index_activity);
    bind(this);

    updateNavigationView();
    adapter = new SimpleItemRecyclerViewAdapter();

    Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
    setSupportActionBar(toolbar);
    toolbar.setTitle(getTitle());

    DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
    ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
      this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
    drawer.addDrawerListener(toggle);
    toggle.syncState();


    list.setAdapter(adapter);

    if (findViewById(R.id.preset_detail_container) != null) {
      // The detail container view will be present only in the
      // large-screen layouts (res/values-w900dp).
      // If this view is present, then the
      // activity should be in two-pane mode.
      mTwoPane = true;
    }
  }

  private void handleIntents(Intent intent) {
    if (Intent.ACTION_VIEW.equals(intent.getAction())) {
      Uri data = intent.getData();
      if ((data != null) && ("dotstar".equals(data.getScheme()))) {
        storeConnectionPrefs(this, data.getHost(), data.getPort());
        return;
      }

      String host = intent.getStringExtra("host");
      int port = intent.getIntExtra("port", 0);
      if (host != null && port != 0) {
        storeConnectionPrefs(this, host, port);
        return;
      }
    }
  }

  private void updateNavigationView() {
    NavigationView view = (NavigationView) findViewById(R.id.nav_view);
    Menu m = view.getMenu();
    dotstars = new DotStarsMenu(this, m, (NsdManager) getSystemService(Context.NSD_SERVICE));
  }


  @Override
  protected void onResume() {
    super.onResume();
    DotStar dotStar = getDotStar(getConnectionPrefs(this));
    if (dotStar == null) {
      showPreferencesSnack();
    } else {
      dotStar.index().enqueue(new Callback<List<Preset>>() {
        @Override
        public void onResponse(Call<List<Preset>> call, Response<List<Preset>> response) {
          adapter.set(response.body());
        }

        @Override
        public void onFailure(Call<List<Preset>> call, Throwable t) {
          showPreferencesSnack();
        }
      });
    }
  }

  @Override
  public void onBackPressed() {
    DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
    if (drawer.isDrawerOpen(GravityCompat.START)) {
      drawer.closeDrawer(GravityCompat.START);
    } else {
      super.onBackPressed();
    }
  }

  @Override
  protected void onPause() {
    super.onPause();
  }

  @Override
  protected void onDestroy() {
    dotstars.destroy();
    super.onDestroy();
  }

  private void showPreferencesSnack() {
    Snackbar.make(coordinator, "Problems with DotStarServer", Snackbar.LENGTH_INDEFINITE).setAction("Preferences", new OnClickListener() {
      @Override
      public void onClick(View view) {
        startActivity(new Intent(Index.this, PreferencesActivity.class));
      }
    }).show();
  }

  @Override
  public boolean onCreateOptionsMenu(Menu menu) {
    // Inflate the menu; this adds items to the action bar if it is present.
    getMenuInflater().inflate(R.menu.menu_main, menu);
    return true;
  }


  @Override
  public boolean onOptionsItemSelected(MenuItem item) {
    // Handle action bar item clicks here. The action bar will
    // automatically handle clicks on the Home/Up button, so long
    // as you specify activity parent activity in AndroidManifest.xml.
    int id = item.getItemId();

    //noinspection SimplifiableIfStatement
    if (id == R.id.action_settings) {
      startActivity(new Intent(this, PreferencesActivity.class));
      return true;
    }

    return super.onOptionsItemSelected(item);
  }


  public class SimpleItemRecyclerViewAdapter
    extends RecyclerView.Adapter<SimpleItemRecyclerViewAdapter.ViewHolder> {

    private List<Preset> mValues = new ArrayList<>();

    public void set(List<Preset> presets) {
      mValues = presets;
      notifyDataSetChanged();
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
      View view = LayoutInflater.from(parent.getContext())
        .inflate(R.layout.preset_list_content, parent, false);
      return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(final ViewHolder holder, int position) {
      holder.mItem = mValues.get(position);
      holder.mContentView.setText(mValues.get(position).name);

      holder.mView.setOnClickListener(new View.OnClickListener() {
        @Override
        public void onClick(View v) {

          if (mTwoPane) {
            Bundle arguments = new Bundle();
            arguments.putSerializable(PresetDetailFragment.ARG_ITEM_ID, holder.mItem);
            PresetDetailFragment fragment = new PresetDetailFragment();
            fragment.setArguments(arguments);
            getSupportFragmentManager().beginTransaction()
              .replace(R.id.preset_detail_container, fragment)
              .commit();
          } else {
            Context context = holder.mContentView.getContext();
            Intent intent = new Intent(context, PresetDetailActivity.class);
            intent.putExtra(PresetDetailFragment.ARG_ITEM_ID, holder.mItem);

            context.startActivity(intent);
          }
        }
      });
    }


    @Override
    public int getItemCount() {
      return mValues.size();
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
      public final View mView;
      public final TextView mContentView;
      public Preset mItem;

      public ViewHolder(View view) {
        super(view);
        mView = view;
        mContentView = (TextView) view.findViewById(R.id.content);
      }

      @Override
      public String toString() {
        return super.toString() + " '" + mContentView.getText() + "'";
      }
    }

  }


}
