//
//  RNVideoEditorPackage.java
//  ReactionSocial
//
//  Created by Vuong Duc Lam on 9/3/19.
//

package com.lamvd0101.RNVideoEditor;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.JavaScriptModule;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class RNVideoEditorPackage implements ReactPackage {
  @Override
  public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
    return Collections.emptyList();
  }

  @Override
  public List<NativeModule> createNativeModules(
          ReactApplicationContext reactContext) {
    List<NativeModule> modules = new ArrayList<>();

    modules.add(new RNVideoEditorModule(reactContext));

    return modules;
  }

  public List<Class<? extends JavaScriptModule>> createJSModules() {
    return null;
  }
}
