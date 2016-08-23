package com.flopcode.dotstar.android;

import okhttp3.OkHttpClient;
import okhttp3.logging.HttpLoggingInterceptor;
import okhttp3.logging.HttpLoggingInterceptor.Level;
import retrofit2.Call;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;
import retrofit2.http.Field;
import retrofit2.http.FieldMap;
import retrofit2.http.FormUrlEncoded;
import retrofit2.http.GET;
import retrofit2.http.Headers;
import retrofit2.http.POST;

import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

public class DotStarApi {

    public static DotStar createDotStar(String urlAsString) {
        Retrofit rf = retrofitWithLogging()
                .baseUrl(urlAsString)
                .addConverterFactory(GsonConverterFactory.create())
                .build();
        return rf.create(DotStar.class);
    }

    public static Retrofit.Builder retrofitWithLogging() {
        HttpLoggingInterceptor logging = new HttpLoggingInterceptor();
        logging.setLevel(Level.BODY);
        OkHttpClient httpClient = new OkHttpClient.Builder()
                .addInterceptor(logging)
                .connectTimeout(2, TimeUnit.SECONDS)
                .readTimeout(2, TimeUnit.SECONDS)
                .writeTimeout(2, TimeUnit.SECONDS)
                .build();
        return new Retrofit.Builder().client(httpClient);
    }

    interface DotStar {
        @GET("/presets")
        @Headers("Accept: application/json")
        Call<List<Preset>> index();

        @FormUrlEncoded
        @POST("/activate")
        Call<Void>  activate(@Field("id") long id);

        @FormUrlEncoded
        @POST("/set")
        Call<Void> set(@FieldMap Map<String, String> data);
    }
}
