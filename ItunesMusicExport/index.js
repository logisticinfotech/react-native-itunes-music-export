import { NativeModules } from 'react-native';

const { RNItunesMusicExport } = require('react-native').NativeModules;

module.exports = {
  getAlltracks: function() {
    return new Promise((resolve, reject) => {
      RNItunesMusicExport.getList('tracks', (err, tracks) => {
        if (err) {
          reject(err);
        } else {
          resolve(tracks);
        }
      });
    });
  },
  getAllPlayList: function() {
    return new Promise((resolve, reject) => {
      RNItunesMusicExport.getList('playlists', (err, playlists) => {
        if (err) {
          reject(err);
        } else {
          resolve(playlists);
        }
      });
    });
  },
  getAllAlbums: function() {
    return new Promise((resolve, reject) => {
      RNItunesMusicExport.getList('albums', (err, albums) => {
        if (err) {
          reject(err);
        } else {
          resolve(albums);
        }
      });
    });
  },
  getAllArtists: function() {
    return new Promise((resolve, reject) => {
      RNItunesMusicExport.getList('artists', (err, artists) => {
        if (err) {
          reject(err);
        } else {
          resolve(artists);
        }
      });
    });
  },
  getAllPodcast: function() {
    return new Promise((resolve, reject) => {
      RNItunesMusicExport.getList('podcasts', (err, podcasts) => {
        if (err) {
          reject(err);
        } else {
          resolve(podcasts);
        }
      });
    });
  },
  getAllAudioBook: function() {
    return new Promise((resolve, reject) => {
      RNItunesMusicExport.getList('audioBooks', (err, audioBooks) => {
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
