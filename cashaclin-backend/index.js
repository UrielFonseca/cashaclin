
const express = require('express');
const mongoose = require('mongoose');
const jwt = require('jsonwebtoken');
const cors = require('cors');

const app = express();

// Configuración de Seguridad y CORS
app.use(cors()); 
app.use(express.json());

// CONFIGURACIÓN CLAVE
const JWT_SECRET = "CashaClinKey2026";
const MONGO_URI = "mongodb+srv://uriel:zgWhoAstqcL8Ww4T@laboratoriofullstack.zfzctxt.mongodb.net/";

// --- MODELOS DE DATOS ---

// Usuario para Login y Roles
const User = mongoose.model('User', {
    email: { type: String, unique: true, required: true },
    password: { type: String, required: true },
    role: { type: String, enum: ['admin', 'customer'], default: 'customer' }
});

// Productos del Catálogo e Inventario
const Product = mongoose.model('Product', {
    name: String, 
    sku: String, 
    category: String, 
    description: String, 
    price: Number, 
    stock: Number, 
    image: String
});

// Clientes (se registran al comprar o por el admin)
const Customer = mongoose.model('Customer', {
    name: String, 
    email: { type: String, unique: true }, 
    phone: String, 
    lastPurchase: Date
});

// Ventas / Pedidos
const Sale = mongoose.model('Sale', {
    customerName: String,
    customerEmail: String,
    total: Number,
    status: { type: String, default: 'Completada' },
    date: { type: Date, default: Date.now },
    items: Array
});

// --- MIDDLEWARE PARA PROTEGER RUTAS (JWT) ---
const auth = (req, res, next) => {
    const token = req.headers['authorization']?.split(' ')[1];
    if (!token) return res.status(401).send('Acceso denegado: No hay token');
    try {
        const verified = jwt.verify(token, JWT_SECRET);
        req.user = verified;
        next();
    } catch (err) {
        res.status(400).send('Token inválido');
    }
};

// --- RUTAS DE LA API ---

// 1. REGISTRO DE USUARIOS
app.post('/api/auth/register', async (req, res) => {
    try {
        const { email, password, role } = req.body;
        console.log(`📝 Intentando registrar a: ${email} con rol ${role}`);
        
        const user = new User({ email, password, role: role || 'customer' });
        await user.save();
        
        res.json({ message: "Usuario registrado con éxito" });
    } catch (err) {
        console.error("❌ Error al registrar:", err.message);
        res.status(400).json({ error: "El correo ya existe o faltan datos" });
    }
});

// 2. LOGIN (JWT)
app.post('/api/auth/login', async (req, res) => {
    const { email, password } = req.body;
    console.log(`🔑 Intento de login: ${email}`);

    try {
        const user = await User.findOne({ email, password });
        
        if (user) {
            console.log(`✅ Login exitoso para: ${user.email} (Rol: ${user.role})`);
            const token = jwt.sign({ id: user._id, role: user.role }, JWT_SECRET, { expiresIn: '24h' });
            return res.json({ token, role: user.role });
        } else {
            console.log(`⚠️ Falló login: Credenciales incorrectas para ${email}`);
            return res.status(401).json({ error: "Email o contraseña incorrectos" });
        }
    } catch (err) {
        res.status(500).json({ error: "Error en el servidor" });
    }
});

// 3. PRODUCTOS (GET y POST)
app.get('/api/products', async (req, res) => {
    const products = await Product.find();
    res.json(products);
});

app.post('/api/products', auth, async (req, res) => {
    const product = new Product(req.body);
    await product.save();
    res.json(product);
});

app.post('/api/products/:id/stock', auth, async (req, res) => {
    await Product.findByIdAndUpdate(req.params.id, { stock: req.body.stock });
    res.json({ success: true });
});

// 4. CLIENTES
app.get('/api/customers', auth, async (req, res) => {
    res.json(await Customer.find());
});

app.post('/api/customers', auth, async (req, res) => {
    const customer = await Customer.findOneAndUpdate(
        { email: req.body.email }, 
        req.body, 
        { upsert: true, new: true }
    );
    res.json(customer);
});

// 5. VENTAS
app.get('/api/sales', auth, async (req, res) => {
    res.json(await Sale.find().sort({ date: -1 }));
});

app.post('/api/sales', async (req, res) => {
    const sale = new Sale(req.body);
    await sale.save();
    // Descontar stock automáticamente
    for (let item of req.body.items) {
        await Product.findByIdAndUpdate(item.productId, { $inc: { stock: -item.qty } });
    }
    res.json(sale);
});

// --- INICIO DEL SERVIDOR ---
mongoose.connect(MONGO_URI)
    .then(() => {
        console.log("🟢 Conectado a MongoDB Atlas");
        app.listen(3000, '0.0.0.0', () => {
            console.log("🚀 Servidor Casha Clin Pro en puerto 3000");
        });
    })
    .catch(err => console.error("🔴 Error al conectar MongoDB:", err));