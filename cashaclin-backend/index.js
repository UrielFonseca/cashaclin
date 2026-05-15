const express = require('express');
const mongoose = require('mongoose');
const jwt = require('jsonwebtoken');
const cors = require('cors');

const app = express();

app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;

const JWT_SECRET = "CashaClinKey2026";

const MONGO_URI = "mongodb+srv://uriel:zgWhoAstqcL8Ww4T@laboratoriofullstack.zfzctxt.mongodb.net/";

// -------------------- MODELOS --------------------

const User = mongoose.model('User', {
    email: {
        type: String,
        unique: true,
        required: true
    },
    password: {
        type: String,
        required: true
    },
    role: {
        type: String,
        enum: ['admin', 'customer'],
        default: 'customer'
    }
});

const Product = mongoose.model('Product', {
    name: String,
    sku: String,
    category: String,
    description: String,
    price: Number,
    stock: Number,
    image: String
});

const Sale = mongoose.model('Sale', {
    customerName: String,
    customerEmail: String,
    total: {
        type: Number,
        default: 0
    },
    status: {
        type: String,
        default: 'Esperando aprobación'
    },
    type: {
        type: String,
        default: 'carrito'
    },
    date: {
        type: Date,
        default: Date.now
    },
    items: {
        type: Array,
        default: []
    },
    comment: String,
    messages: [{
        sender: String,
        text: String,
        date: {
            type: Date,
            default: Date.now
        }
    }]
});

const Customer = mongoose.model('Customer', {
    name: String,
    email: {
        type: String,
        unique: true
    },
    phone: String
});

// -------------------- MIDDLEWARE JWT --------------------

const auth = (req, res, next) => {

    const token = req.headers['authorization']?.split(' ')[1];

    if (!token) {
        return res.status(401).send('No autorizado');
    }

    try {

        const decoded = jwt.verify(token, JWT_SECRET);

        req.user = decoded;

        next();

    } catch (err) {

        return res.status(400).send('Token inválido');
    }
};

// -------------------- RUTAS AUTH --------------------

app.post('/api/auth/register', async (req, res) => {

    try {

        const user = new User(req.body);

        await user.save();

        res.json({
            success: true
        });

    } catch (err) {

        console.log(err);

        res.status(400).json({
            error: err.message
        });
    }
});

app.post('/api/auth/login', async (req, res) => {

    try {

        const { email, password } = req.body;

        const user = await User.findOne({
            email,
            password
        });

        if (!user) {

            return res.status(401).json({
                error: "Credenciales inválidas"
            });
        }

        const token = jwt.sign(
            {
                id: user._id,
                email: user.email,
                role: user.role
            },
            JWT_SECRET
        );

        res.json({
            token,
            role: user.role
        });

    } catch (err) {

        console.log(err);

        res.status(500).json({
            error: "Error en login"
        });
    }
});

// -------------------- PRODUCTOS --------------------

app.get('/api/products', async (req, res) => {

    try {

        const products = await Product.find();

        res.json(products);

    } catch (err) {

        res.status(500).json({
            error: err.message
        });
    }
});

app.post('/api/products', auth, async (req, res) => {

    try {

        const product = new Product(req.body);

        await product.save();

        res.json(product);

    } catch (err) {

        res.status(400).json({
            error: err.message
        });
    }
});

app.put('/api/products/:id', auth, async (req, res) => {

    try {

        await Product.findByIdAndUpdate(req.params.id, req.body);

        res.json({
            success: true
        });

    } catch (err) {

        res.status(400).json({
            error: err.message
        });
    }
});

app.delete('/api/products/:id', auth, async (req, res) => {

    try {

        await Product.findByIdAndDelete(req.params.id);

        res.json({
            success: true
        });

    } catch (err) {

        res.status(400).json({
            error: err.message
        });
    }
});

// -------------------- VENTAS --------------------

app.get('/api/sales', auth, async (req, res) => {

    try {

        const sales = await Sale.find().sort({ date: -1 });

        res.json(sales);

    } catch (err) {

        res.status(500).json({
            error: err.message
        });
    }
});

app.get('/api/sales/my', auth, async (req, res) => {

    try {

        const sales = await Sale.find({
            customerEmail: req.user.email
        }).sort({ date: -1 });

        res.json(sales);

    } catch (err) {

        res.status(500).json({
            error: err.message
        });
    }
});

app.post('/api/sales', auth, async (req, res) => {

    try {

        const sale = new Sale({
            ...req.body,
            customerEmail: req.user.email
        });

        await sale.save();

        if (
            req.body.type === 'carrito' &&
            Array.isArray(req.body.items)
        ) {

            for (let item of req.body.items) {

                await Product.findByIdAndUpdate(
                    item.productId,
                    {
                        $inc: {
                            stock: -item.qty
                        }
                    }
                );
            }
        }

        res.json(sale);

    } catch (err) {

        res.status(400).json({
            error: err.message
        });
    }
});

app.put('/api/sales/:id/negotiate', auth, async (req, res) => {

    try {

        const { total, status, message } = req.body;

        const sale = await Sale.findById(req.params.id);

        if (!sale) {

            return res.status(404).json({
                error: "Venta no encontrada"
            });
        }

        if (total !== undefined) {
            sale.total = total;
        }

        if (status) {
            sale.status = status;
        }

        if (message) {

            sale.messages.push({
                sender: req.user.role,
                text: message
            });
        }

        await sale.save();

        res.json({
            success: true
        });

    } catch (err) {

        res.status(400).json({
            error: err.message
        });
    }
});

// -------------------- CLIENTES --------------------

app.get('/api/customers', auth, async (req, res) => {

    try {

        const customers = await Customer.find();

        res.json(customers);

    } catch (err) {

        res.status(500).json({
            error: err.message
        });
    }
});

app.post('/api/customers', auth, async (req, res) => {

    try {

        const customer = new Customer(req.body);

        await customer.save();

        res.json(customer);

    } catch (err) {

        res.status(400).json({
            error: err.message
        });
    }
});

app.put('/api/customers/:id', auth, async (req, res) => {

    try {

        await Customer.findByIdAndUpdate(
            req.params.id,
            req.body
        );

        res.json({
            success: true
        });

    } catch (err) {

        res.status(400).json({
            error: err.message
        });
    }
});

app.delete('/api/customers/:id', auth, async (req, res) => {

    try {

        await Customer.findByIdAndDelete(req.params.id);

        res.json({
            success: true
        });

    } catch (err) {

        res.status(400).json({
            error: err.message
        });
    }
});

// -------------------- TEST API --------------------

app.get('/', (req, res) => {

    res.send('API funcionando correctamente');
});

// -------------------- CONEXION MONGO --------------------

mongoose.connect(MONGO_URI)

.then(() => {

    console.log("Mongo conectado");

    app.listen(PORT, '0.0.0.0', () => {

        console.log(`Backend Casha Clin Pro Activo en puerto ${PORT}`);
    });

})

.catch((err) => {

    console.log("Error MongoDB:", err);
});