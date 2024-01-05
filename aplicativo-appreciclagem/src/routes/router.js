import React, { useContext } from 'react';
import AuthStack from "./AuthStack";
import AppStack from "./AppStack";
import { AuthContext } from '../contexts/authContext';

export default function Routes() {
    const { authState } = useContext(AuthContext);

    return(  
        authState ? <AppStack /> : <AuthStack />      
    )
}