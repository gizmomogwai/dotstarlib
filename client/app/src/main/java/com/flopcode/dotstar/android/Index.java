package com.flopcode.dotstar.android;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences.Editor;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.design.widget.CoordinatorLayout;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
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
 * An activity representing a list of Presets. This activity
 * has different presentations for handset and tablet-size devices. On
 * handsets, the activity presents a list of items, which when touched,
 * lead to a {@link PresetDetailActivity} representing
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
   * Whether or not the activity is in two-pane mode, i.e. running on a tablet
   * device.
   */
  private boolean mTwoPane;
  private SimpleItemRecyclerViewAdapter adapter;

  public static String getConnectionPrefs(Context c) {
    return PreferenceManager.getDefaultSharedPreferences(c).getString(DOT_STAR_SERVER, "");
  }

  public static void storeConnectionPrefs(Context c, String connection) {
    Editor e = PreferenceManager.getDefaultSharedPreferences(c).edit();
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
    final Intent intent = getIntent();
    if (Intent.ACTION_VIEW.equals(intent.getAction())) {
      String host = intent.getStringExtra("host");
      int port = intent.getIntExtra("port", 4567);
      storeConnectionPrefs(this, "http://" + host + ":" + port);
    }
    setContentView(R.layout.activity_preset_list);
    bind(this);

    adapter = new SimpleItemRecyclerViewAdapter();

    Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
    setSupportActionBar(toolbar);
    toolbar.setTitle(getTitle());
/*
    FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
    fab.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View view) {
        Snackbar.make(view, "Replace with your own action", Snackbar.LENGTH_LONG)
          .setAction("Action", null).show();
      }
    });
*/
    list.setAdapter(adapter);

    if (findViewById(R.id.preset_detail_container) != null) {
      // The detail container view will be present only in the
      // large-screen layouts (res/values-w900dp).
      // If this view is present, then the
      // activity should be in two-pane mode.
      mTwoPane = true;
    }
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
    // as you specify a parent activity in AndroidManifest.xml.
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
      holder.mIdView.setText("" + mValues.get(position).id);
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
            Context context = holder.mIdView.getContext();
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
      public final TextView mIdView;
      public final TextView mContentView;
      public Preset mItem;

      public ViewHolder(View view) {
        super(view);
        mView = view;
        mIdView = (TextView) view.findViewById(R.id.id);
        mContentView = (TextView) view.findViewById(R.id.content);
      }

      @Override
      public String toString() {
        return super.toString() + " '" + mContentView.getText() + "'";
      }
    }

  }


}
