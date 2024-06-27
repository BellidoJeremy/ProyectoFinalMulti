const express = require('express');
const router = express.Router();
const db = require('./db');

// Crear una nueva tarea
router.post('/tareas', (req, res) => {
  const { titulo, descripcion, fecha, completado } = req.body;
  const sql = `INSERT INTO tareas (titulo, descripcion, fecha, completado) VALUES (?, ?, ?, ?)`;
  db.query(sql, [titulo, descripcion, fecha, completado], (error, results) => {
    if (error) {
      res.status(500).send(error);
    } else {
      res.status(201).send({ id: results.insertId, ...req.body });
    }
  });
});

// Obtener todas las tareas
router.get('/tareas', (req, res) => {
  const sql = 'SELECT * FROM tareas';
  db.query(sql, (error, results) => {
    if (error) {
      res.status(500).send(error);
    } else {
      res.status(200).send(results);
    }
  });
});

// Obtener una tarea por ID
router.get('/tareas/:id', (req, res) => {
  const { id } = req.params;
  const sql = 'SELECT * FROM tareas WHERE id = ?';
  db.query(sql, [id], (error, results) => {
    if (error) {
      res.status(500).send(error);
    } else if (results.length === 0) {
      res.status(404).send({ message: 'Tarea no encontrada' });
    } else {
      res.status(200).send(results[0]);
    }
  });
});

// Actualizar una tarea por ID
router.patch('/tareas/:id', (req, res) => {
  const { id } = req.params;
  const { titulo, descripcion, fecha, completado } = req.body;
  const sql = `UPDATE tareas SET titulo = ?, descripcion = ?, fecha = ?, completado = ? WHERE id = ?`;
  db.query(sql, [titulo, descripcion, fecha, completado, id], (error, results) => {
    if (error) {
      res.status(500).send(error);
    } else if (results.affectedRows === 0) {
      res.status(404).send({ message: 'Tarea no encontrada' });
    } else {
      res.status(200).send({ id, ...req.body });
    }
  });
});

// Eliminar una tarea por ID
router.delete('/tareas/:id', (req, res) => {
  const { id } = req.params;
  const sql = 'DELETE FROM tareas WHERE id = ?';
  db.query(sql, [id], (error, results) => {
    if (error) {
      res.status(500).send(error);
    } else if (results.affectedRows === 0) {
      res.status(404).send({ message: 'Tarea no encontrada' });
    } else {
      res.status(200).send({ message: 'Tarea eliminada' });
    }
  });
});

module.exports = router;
