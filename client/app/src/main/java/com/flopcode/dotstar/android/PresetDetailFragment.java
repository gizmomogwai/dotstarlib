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
import android.widget.SeekBar;
import android.widget.SeekBar.OnSeekBarChangeListener;
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
    for (Map<String, String> parameters : mItem.parameters) {
      Parameter p = Parameters.get(parameters);
      Button b = p.createButton(inflater, rootView, getContext());
      if (b != null) {
        rootView.addView(b);
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

  static abstract class Parameter {
    public final String name;

    Parameter(Map<String, String> params) {
      if (!params.containsKey("name")) {
        throw new IllegalArgumentException();
      }
      this.name = params.get("name");
    }

    public abstract Button createButton(LayoutInflater inflater, ViewGroup rootView, Context context);
  }

  private static class ColorParameter extends Parameter {
    public ColorParameter(Map<String, String> params) {
      super(params);
    }

    @Override
    public Button createButton(LayoutInflater inflater, ViewGroup rootView, final Context context) {
      final Button res = (Button) inflater.inflate(R.layout.preset_color_button, rootView, false);
      res.setText(name);
      res.setOnClickListener(new OnClickListener() {
        @Override
        public void onClick(View view) {
          showColorPicker();
        }

        private void showColorPicker() {
          ColorPickerDialogBuilder
            .with(context)
            .setTitle("Choose color for " + name)
            .initialColor(0xffffffff)
            .wheelType(WHEEL_TYPE.FLOWER)
            .showAlphaSlider(false)
            .density(30)
            .setOnColorSelectedListener(new OnColorSelectedListener() {
              @Override
              public void onColorSelected(int selectedColor) {
                Call<Void> call = getDotStar(getConnectionPrefs(context)).set(ImmutableMap.of(name, Integer.toHexString(selectedColor)));
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
      return res;
    }
  }

  private static class RangeParameter extends Parameter {
    public final Float min;
    public final Float max;

    public RangeParameter(Map<String, String> map) {
      super(map);
      min = new Float(map.get("min"));
      max = new Float(map.get("max"));
    }

    @Override
    public Button createButton(LayoutInflater inflater, ViewGroup rootView, final Context context) {
      final Button res = (Button) inflater.inflate(R.layout.preset_color_button, rootView, false);
      res.setText(name);
      res.setOnClickListener(new OnClickListener() {
        float value = min;

        @Override
        public void onClick(View view) {
          SeekBar seekBar = new SeekBar(context);
          seekBar.setMax((int) ((max - min) * 10));
          final AlertDialog alertDialog = new Builder(context)
            .setTitle(calculateTitle())
            .setView(seekBar)
            .setPositiveButton("Ok", new DialogInterface.OnClickListener() {
              @Override
              public void onClick(DialogInterface dialogInterface, int i) {
              }
            })
            .create();
          alertDialog.show();
          seekBar.setOnSeekBarChangeListener(new OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
              System.out.println("seekBar = " + seekBar);
              value = (i / 10.0f) + min;
              alertDialog.setTitle(calculateTitle());
              Call<Void> call = getDotStar(getConnectionPrefs(context)).set(ImmutableMap.of(name, String.format("%.1f", value)));
              call.enqueue(new Callback<Void>() {
                @Override
                public void onResponse(Call<Void> call, Response<Void> response) {
                  Log.e(Index.LOG_TAG, "could set " + name);
                }

                @Override
                public void onFailure(Call<Void> call, Throwable t) {
                  Log.e(Index.LOG_TAG, "could not set " + name, t);
                }
              });
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
          });
        }

        private String calculateTitle() {
          return "Range " + name + "(" + String.format("%.1f", value) + "/" + min + " - " + max + ")";
        }
      });
      return res;
    }
  }

  static class Parameters {
    public static Parameter get(Map<String, String> params) {
      final String type = params.get("type");
      if (type.equals("color")) {
        return new ColorParameter(params);
      } else if (type.equals("range")) {
        return new RangeParameter(params);
      }
      return null;
    }
  }
}
