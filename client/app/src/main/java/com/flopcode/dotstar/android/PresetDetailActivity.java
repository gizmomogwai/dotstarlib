package com.flopcode.dotstar.android;

import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.MenuItem;
import android.view.View;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

import static com.flopcode.dotstar.android.Index.getConnectionPrefs;

/**
 * An activity representing a single com.flopcode.dotstar.android.Preset detail screen. This
 * activity is only used narrow width devices. On tablet-size devices,
 * item details are presented side-by-side with a list of items
 * in a {@link Index}.
 */
public class PresetDetailActivity extends AppCompatActivity {

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_preset_detail);
    final Toolbar toolbar = (Toolbar) findViewById(R.id.detail_toolbar);
    setSupportActionBar(toolbar);

    final Preset preset = (Preset) getIntent().getSerializableExtra(PresetDetailFragment.ARG_ITEM_ID);
    Call<Void> activate = Index.getDotStar(getConnectionPrefs(this)).activate(preset.name);
    activate.enqueue(new Callback<Void>() {
      @Override
      public void onResponse(Call<Void> call, Response<Void> response) {
        Snackbar.make(toolbar.getRootView(), "Activated '" + preset.name + "'", Snackbar.LENGTH_LONG)
          .setAction("Action", null).show();
      }

      @Override
      public void onFailure(Call<Void> call, Throwable t) {
        Snackbar.make(toolbar.getRootView(), "Failed activating '" + preset.name + "'", Snackbar.LENGTH_LONG)
          .setAction("Action", null).show();

      }
    });

    FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
    fab.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(final View view) {

      }
    });

    // Show the Up button in the action bar.
    ActionBar actionBar = getSupportActionBar();
    if (actionBar != null) {
      actionBar.setDisplayHomeAsUpEnabled(true);
    }

    // savedInstanceState is non-null when there is fragment state
    // saved from previous configurations of this activity
    // (e.g. when rotating the screen from portrait to landscape).
    // In this case, the fragment will automatically be re-added
    // to its container so we don't need to manually add it.
    // For more information, see the Fragments API guide at:
    //
    // http://developer.android.com/guide/components/fragments.html
    //
    if (savedInstanceState == null) {
      // Create the detail fragment and add it to the activity
      // using a fragment transaction.
      Bundle arguments = new Bundle();
      arguments.putSerializable(PresetDetailFragment.ARG_ITEM_ID,
        preset);
      PresetDetailFragment fragment = new PresetDetailFragment();
      fragment.setArguments(arguments);
      getSupportFragmentManager().beginTransaction()
        .add(R.id.preset_detail_container, fragment)
        .commit();
    }
  }

  @Override
  public boolean onOptionsItemSelected(MenuItem item) {
    int id = item.getItemId();
    if (id == android.R.id.home) {
      // This ID represents the Home or Up button. In the case of this
      // activity, the Up button is shown. For
      // more details, see the Navigation pattern on Android Design:
      //
      // http://developer.android.com/design/patterns/navigation.html#up-vs-back
      //
      navigateUpTo(new Intent(this, Index.class));
      return true;
    }
    return super.onOptionsItemSelected(item);
  }
}
