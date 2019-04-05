import { NativeModules } from 'react-native';

const { RNItunesMusicExport } = require('react-native').NativeModules;

module.exports = {
  getAlltracks: function() {
    return new Promise((resolve, reject) => {
      RNItunesMusicExport.getList((err, tracks) => {
        if (err) {
          reject(err);
        } else {
          resolve(tracks);
        }
      });
    });
  },
};

export default RNItunesMusicExport;
