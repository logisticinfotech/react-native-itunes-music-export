import { NativeModules } from 'react-native';

const { RNItunesMusicExport } = require('react-native').NativeModules;

module.exports = {
  getAlltracks: function(params) {
    return new Promise((resolve, reject) => {
      RNItunesMusicExport.getList('tracks', params, (err, trackLists) => {
        if (err) {
          reject(err);
        } else {
          resolve(trackLists);
        }
      });
    });
  },
  getAllPlayList: function(params) {
    return new Promise((resolve, reject) => {
      RNItunesMusicExport.getList('playlists', params, (err, playlists) => {
        if (err) {
          reject(err);
        } else {
          resolve(playlists);
        }
      });
    });
  },
  getAllAlbums: function(params) {
    return new Promise((resolve, reject) => {
      RNItunesMusicExport.getList('albums', params, (err, albums) => {
        if (err) {
          reject(err);
        } else {
          resolve(albums);
        }
      });
    });
  },
  getAllArtists: function(params) {
    return new Promise((resolve, reject) => {
      RNItunesMusicExport.getList('artists', params, (err, artists) => {
        if (err) {
          reject(err);
        } else {
          resolve(artists);
        }
      });
    });
  },
  getAllPodcast: function(params) {
    return new Promise((resolve, reject) => {
      RNItunesMusicExport.getList('podcasts', params, (err, podcasts) => {
        if (err) {
          reject(err);
        } else {
          resolve(podcasts);
        }
      });
    });
  },
  getAllAudioBook: function(params) {
    return new Promise((resolve, reject) => {
      RNItunesMusicExport.getList('audioBooks', params, (err, audioBooks) => {
        if (err) {
          reject(err);
        } else {
          resolve(audioBooks);
        }
      });
    });
  },
};

export default RNItunesMusicExport;
