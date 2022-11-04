<template>
    <header class="header-global">
        <base-nav class="navbar-main" transparent type="" effect="light" expand>
            <router-link slot="brand" class="navbar-brand mr-lg-5" to="/">
                Home
            </router-link>
            <router-link slot="brand" class="navbar-brand mr-lg-5" to="/train">
                Train
            </router-link>
            <router-link slot="brand" class="navbar-brand mr-lg-5" to="/infer">
                Infer
            </router-link>
            <router-link slot="brand" class="navbar-brand mr-lg-5" to="/model">
                Model
            </router-link>

            <div class="row" slot="content-header" slot-scope="{closeMenu}">
                <div class="col-6 collapse-brand">
                    <h3 class="lead">Account Management</h3>
                </div>
                <div class="col-6 collapse-close">
                    <close-button @click="closeMenu"></close-button>
                </div>
            </div>
            <ul class="navbar-nav align-items-lg-center ml-lg-auto">
                <li class="nav-item d-none d-lg-block ml-lg-4">
                    <a class="nav-link nav-link-icon" href="https://github.com/6iKezbAD3CZnf/blockchained-learning" target="_blank" rel="noopener" data-toggle="tooltip">
                        <i class="fa fa-github"></i>
                        <span class="nav-link-inner--text d-lg-none">Github</span>
                    </a>
                </li>
                <li class="nav-item d-lg-block mt-1">
                    <SwitchChain/>
                </li>
                <li class="nav-item d-lg-block mt-1">
                    <ConnectMetaMask/>
                </li>
            </ul>
        </base-nav>
    </header>
</template>
<script>
import web3Interface from "../web3Interface";

import BaseNav from "../argon/components/BaseNav";
import BaseDropdown from "../argon/components/BaseDropdown";
import CloseButton from "../argon/components/CloseButton";
import ConnectMetaMask from "../components/ConnectMetaMask";
import SwitchChain from "../components/SwitchChain";

export default {
    components: {
        BaseNav,
        CloseButton,
        BaseDropdown,
        ConnectMetaMask,
        SwitchChain
    }
};
</script>
<style>
</style>
