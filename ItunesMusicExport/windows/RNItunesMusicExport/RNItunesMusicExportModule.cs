using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.ApplicationModel.Core;
using Windows.UI.Core;

namespace Itunes.Music.Export.RNItunesMusicExport
{
    /// <summary>
    /// A module that allows JS to share data.
    /// </summary>
    class RNItunesMusicExportModule : NativeModuleBase
    {
        /// <summary>
        /// Instantiates the <see cref="RNItunesMusicExportModule"/>.
        /// </summary>
        internal RNItunesMusicExportModule()
        {

        }

        /// <summary>
        /// The name of the native module.
        /// </summary>
        public override string Name
        {
            get
            {
                return "RNItunesMusicExport";
            }
        }
    }
}
