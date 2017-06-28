package com.flopcode.dotstar.android;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.content.Context;
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
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.SeekBar;
import android.widget.SeekBar.OnSeekBarChangeListener;
import com.flask.colorpicker.ColorPickerView.WHEEL_TYPE;
import com.flask.colorpicker.OnColorSelectedListener;
import com.flask.colorpicker.builder.ColorPickerClickListener;
import com.flask.colorpicker.builder.ColorPickerDialogBuilder;
import com.flopcode.dotstar.android.parameters.Parameter;
import com.google.common.base.Predicate;
import com.google.common.collect.ImmutableMap;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

import java.lang.reflect.Constructor;
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
    for (Map<String, String> parameters : mItem.parameters) {
      Parameter p = Parameters.get(parameters);
      View view = p.createButton(inflater, rootView, getContext());
      if (view != null) {
        rootView.addView(view);
      }
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

  static class Parameters {
    public static Parameter get(Map<String, String> params) {
      final String type = params.get("type");
      String className = "com.flopcode.dotstar.android.parameters." +
        type.substring(0, 1).toUpperCase() + type.substring(1) +
        "Parameter";
      try {
        Constructor<Parameter> p = (Constructor<Parameter>) Class.forName(className).getConstructor(Map.class);
        return p.newInstance(params);
      } catch (Exception e) {
        throw new RuntimeException(e);
      }
    }
  }
}
