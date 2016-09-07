package com.flopcode.dotstar.android;

import android.app.Activity;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.design.widget.CollapsingToolbarLayout;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Button;
import com.flask.colorpicker.ColorPickerView.WHEEL_TYPE;
import com.flask.colorpicker.OnColorSelectedListener;
import com.flask.colorpicker.builder.ColorPickerClickListener;
import com.flask.colorpicker.builder.ColorPickerDialogBuilder;
import com.google.common.base.Predicate;
import com.google.common.collect.ImmutableMap;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

import java.util.Arrays;
import java.util.Map;

import static com.flopcode.dotstar.android.Index.getConnectionPrefs;
import static com.flopcode.dotstar.android.Index.getDotStar;
import static com.google.common.collect.Iterables.filter;

/**
 * A fragment representing a single com.flopcode.dotstar.android.Preset detail screen.
 * This fragment is either contained in a {@link Index}
 * in two-pane mode (on tablets) or a {@link PresetDetailActivity}
 * on handsets.
 */
public class PresetDetailFragment extends Fragment {
  /**
   * The fragment argument representing the item ID that this fragment
   * represents.
   */
  public static final String ARG_ITEM_ID = "item_id";

  /**
   * The dummy content this fragment is presenting.
   */
  private Preset mItem;

  /**
   * Mandatory empty constructor for the fragment manager to instantiate the
   * fragment (e.g. upon screen orientation changes).
   */
  public PresetDetailFragment() {
  }

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    if (getArguments().containsKey(ARG_ITEM_ID)) {
      // Load the dummy content specified by the fragment
      // arguments. In a real-world scenario, use a Loader
      // to load content from a content provider.
      mItem = (Preset) getArguments().getSerializable(ARG_ITEM_ID);

      Activity activity = this.getActivity();
      CollapsingToolbarLayout appBarLayout = (CollapsingToolbarLayout) activity.findViewById(R.id.toolbar_layout);
      if (appBarLayout != null) {
        appBarLayout.setTitle(mItem.name);
      }
    }
  }

  @Override
  public View onCreateView(LayoutInflater inflater, final ViewGroup container,
                           Bundle savedInstanceState) {
    ViewGroup rootView = (ViewGroup) inflater.inflate(R.layout.preset_detail, container, false);

    for (final Map<String, String> parameter : getColorParameters()) {
      final Button button = (Button) inflater.inflate(R.layout.preset_color_button, rootView, false);
      button.setText(parameter.get("name"));
      button.setOnClickListener(new OnClickListener() {
        @Override
        public void onClick(View view) {
          showColorPicker();
        }

        private void showColorPicker() {
          ColorPickerDialogBuilder
            .with(getContext())
            .setTitle("Choose color for " + parameter.get("name"))
            .initialColor(0xffffffff)
            .wheelType(WHEEL_TYPE.FLOWER)
            .showAlphaSlider(false)
            .density(30)
            .setOnColorSelectedListener(new OnColorSelectedListener() {
              @Override
              public void onColorSelected(int selectedColor) {
                Call<Void> call = getDotStar(getConnectionPrefs(getContext())).set(ImmutableMap.of("color", Integer.toHexString(selectedColor)));
                call.enqueue(new Callback<Void>() {
                  @Override
                  public void onResponse(Call<Void> call, Response<Void> response) {
                    Log.e(Index.LOG_TAG, "could set color");
                  }

                  @Override
                  public void onFailure(Call<Void> call, Throwable t) {
                    Log.e(Index.LOG_TAG, "could not set color", t);
                  }
                });
              }
            })
            .setPositiveButton("ok", new ColorPickerClickListener() {
              @Override
              public void onClick(DialogInterface dialog, int selectedColor, Integer[] allColors) {
                System.out.println("ok clicked");
              }
            })
            .setNegativeButton("cancel", new DialogInterface.OnClickListener() {
              @Override
              public void onClick(DialogInterface dialog, int which) {
                System.out.println("cancel clicked");
              }
            })
            .build()
            .show();
        }
      });
      rootView.addView(button);
    }
    return rootView;
  }

  private Iterable<Map<String, String>> getColorParameters() {
    return filter(Arrays.asList(mItem.parameters), new Predicate<Map<String, String>>() {
      @Override
      public boolean apply(Map<String, String> input) {
        return input.containsKey("type") && input.get("type").equals("color");
      }
    });
  }
}
