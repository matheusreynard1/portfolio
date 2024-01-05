import React from 'react';
import { NavigationContainer } from '@react-navigation/native'
import Routes from './src/routes/router'
import AuthProvider from './src/contexts/authContext';

export default function App() {

  return (    
    <NavigationContainer> 
      <AuthProvider>
        <Routes />
      </AuthProvider>
    </NavigationContainer>
  );
}