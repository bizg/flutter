"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
const express_1 = __importDefault(require("express"));
const ws_1 = require("ws");
const core_1 = require("@aries-framework/core");
const node_1 = require("@aries-framework/node");
class index {
    constructor() {
        this.configureRoute();
    }
    port = process.env.AGENT_PORT ? Number(process.env.AGENT_PORT) : 3002;
    app = (0, express_1.default)();
    socketServer = new ws_1.Server({ noServer: true });
    endpoints = process.env.AGENT_ENDPOINTS?.split(',') ?? [`http://localhost:${this.port}`, `ws://localhost:${this.port}`];
    agentConfig = {
        endpoints: this.endpoints,
        label: process.env.AGENT_LABEL || 'Aries Framework JavaScript Mediator',
        walletConfig: {
            id: process.env.WALLET_NAME || 'AriesFrameworkJavaScript',
            key: process.env.WALLET_KEY || 'AriesFrameworkJavaScript',
        },
        autoAcceptConnections: true,
        autoAcceptMediationRequests: true,
    };
    agent;
    config;
    transports;
    createAgent() {
        this.agent = new core_1.Agent(this.agentConfig, node_1.agentDependencies);
    }
    getConfig() {
        this.config = this.agent.injectionContainer.resolve(core_1.AgentConfig);
    }
    createTransports() {
        const httpInboundTransport = new node_1.HttpInboundTransport({ app: this.app, port: this.port });
        const httpOutboundTransport = new core_1.HttpOutboundTransport();
        const wsInboundTransport = new node_1.WsInboundTransport({ server: this.socketServer });
        const wsOutboundTransport = new core_1.WsOutboundTransport();
        this.transports = {
            httpInboundTransport: httpInboundTransport,
            httpOutboundTransport: httpOutboundTransport,
            wsInboundTransport: wsInboundTransport,
            wsOutboundTransport: wsOutboundTransport
        };
    }
    registerTransports() {
        this.createAgent();
        this.createTransports();
        this.agent.registerInboundTransport(this.transports.httpInboundTransport);
        this.agent.registerOutboundTransport(this.transports.httpOutboundTransport);
        this.agent.registerInboundTransport(this.transports.wsInboundTransport);
        this.agent.registerOutboundTransport(this.transports.wsOutboundTransport);
    }
    configureRoute() {
        this.registerTransports();
        this.getConfig();
        this.transports.httpInboundTransport.app.get('/invitation', async (req, res) => {
            const { invitation } = await this.agent.connections.createConnection();
            const httpEndpoint = this.config.endpoints.find((e) => e.startsWith('http'));
            const c_i = invitation.toUrl({ domain: httpEndpoint + '/invitation' });
            const response = await core_1.ConnectionInvitationMessage.fromUrl(c_i);
            res.send(response.toJSON());
        });
    }
    async run() {
        await this.agent.initialize();
        this.transports.httpInboundTransport.server?.on('upgrade', (request, socket, head) => {
            this.socketServer.handleUpgrade(request, socket, head, (socket) => {
                this.socketServer.emit('connection', socket, request);
            });
        });
    }
}
module.exports = index;
